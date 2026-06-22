//
//  RemotePlacesService.swift
//  Roamly
//
//  A live implementation of `PlacesDataProviding` backed by the Foursquare
//  Places API. It reuses the curated city anchors for enumeration/resolution
//  (so the city picker and nearest-city logic keep working) but fetches the
//  actual places live, by intention, around the city center.
//
//  Activate by setting ROAMLY_PLACES_PROVIDER=foursquare and FOURSQUARE_API_KEY
//  in the environment. With no key it throws, and `AppEnvironment` keeps the
//  mock provider as the default so the app always works offline.
//

import Foundation

final class RemotePlacesService: PlacesDataProviding {

    enum RemoteError: LocalizedError {
        case missingAPIKey
        case badResponse

        var errorDescription: String? {
            switch self {
            case .missingAPIKey: return "No Foursquare API key configured."
            case .badResponse: return "The places service returned an unexpected response."
            }
        }
    }

    private let apiKey: String?
    private let session: URLSession
    /// City anchors (metadata only) reused from the curated catalog so the
    /// picker and resolver behave identically to the mock provider.
    private let cityAnchors: [City]

    init(apiKey: String? = RoamlyConfig.foursquareAPIKey,
         session: URLSession = .shared,
         cityAnchors: [City]? = nil) {
        self.apiKey = apiKey
        self.session = session
        self.cityAnchors = cityAnchors ?? SampleData.cities.map(RemotePlacesService.stripPlaces)
    }

    // MARK: PlacesDataProviding

    func allCities() async -> [City] {
        cityAnchors.sorted { $0.name < $1.name }
    }

    func city(withID id: String) async -> City? {
        cityAnchors.first { $0.id == id }
    }

    func nearestCity(to coordinate: Coordinate, maxRadiusMeters: Double) async -> City? {
        cityAnchors
            .map { ($0, $0.center.distance(to: coordinate)) }
            .filter { $0.1 <= maxRadiusMeters }
            .min { $0.1 < $1.1 }?
            .0
    }

    func places(in city: City, matching intention: Intention) async -> [Place] {
        do {
            return try await fetchPlaces(near: city.center, intention: intention)
        } catch {
            // Network/credential failure — fail soft with an empty list so the
            // engine reports a friendly "no places" state rather than crashing.
            return []
        }
    }

    // MARK: Networking

    private func fetchPlaces(near coordinate: Coordinate, intention: Intention) async throws -> [Place] {
        guard let apiKey, !apiKey.isEmpty else { throw RemoteError.missingAPIKey }

        var components = URLComponents(string: "https://api.foursquare.com/v3/places/search")!
        components.queryItems = [
            URLQueryItem(name: "ll", value: "\(coordinate.latitude),\(coordinate.longitude)"),
            URLQueryItem(name: "radius", value: "4000"),
            URLQueryItem(name: "limit", value: "30"),
            URLQueryItem(name: "sort", value: "RATING")
        ]
        if let categories = Self.foursquareCategories[intention], !categories.isEmpty {
            components.queryItems?.append(URLQueryItem(name: "categories", value: categories.joined(separator: ",")))
        }

        var request = URLRequest(url: components.url!)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw RemoteError.badResponse
        }

        let decoded = try JSONDecoder().decode(FoursquareSearchResponse.self, from: data)
        return decoded.results.compactMap { $0.toPlace(intention: intention) }
    }

    // MARK: Helpers

    private static func stripPlaces(_ city: City) -> City {
        City(
            id: city.id,
            name: city.name,
            country: city.country,
            countryFlag: city.countryFlag,
            center: city.center,
            neighborhoods: city.neighborhoods,
            places: []
        )
    }

    /// Maps a Roamly intention to Foursquare category IDs.
    /// TODO: Expand/tune these mappings against the live category taxonomy.
    static let foursquareCategories: [Intention: [String]] = [
        .history: ["16007", "10027"],          // Monument, History Museum
        .artCulture: ["10004", "10027"],       // Art Gallery, Museum
        .sports: ["18000"],                    // Sports & Recreation
        .foodie: ["13000"],                    // Dining and Drinking
        .architecture: ["16000"],              // Landmarks & Outdoors
        .familyFriendly: ["10056"],            // Theme Park / Family
        .natureParks: ["16032", "16033"],      // Park, Garden
        .hiddenGems: [],                       // No filter — let rating surface gems
        .shopping: ["17000"],                  // Retail
        .nightlife: ["10032"],                 // Nightlife / Bar
        .photography: ["16003"],               // Scenic Lookout
        .religiousHeritage: ["12100"],         // Spiritual Center
        .localClassics: [],
        .surpriseMe: []
    ]
}
