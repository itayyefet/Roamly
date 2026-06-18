//
//  FoursquareDTO.swift
//  Roamly
//
//  Decodable models for the Foursquare Places API (v3) plus mapping into
//  Roamly's domain `Place`. Kept separate so the network layer stays thin and
//  the mapping is unit-testable without hitting the network.
//

import Foundation

struct FoursquareSearchResponse: Decodable {
    let results: [FoursquarePlace]
}

struct FoursquarePlace: Decodable {
    let fsqID: String
    let name: String
    let categories: [FoursquareCategory]
    let geocodes: FoursquareGeocodes?
    let location: FoursquareLocation?
    let rating: Double?      // 0...10
    let price: Int?          // 1...4

    enum CodingKeys: String, CodingKey {
        case fsqID = "fsq_id"
        case name, categories, geocodes, location, rating, price
    }
}

struct FoursquareCategory: Decodable {
    let name: String
}

struct FoursquareGeocodes: Decodable {
    let main: FoursquareLatLon?
}

struct FoursquareLatLon: Decodable {
    let latitude: Double
    let longitude: Double
}

struct FoursquareLocation: Decodable {
    let formattedAddress: String?

    enum CodingKeys: String, CodingKey {
        case formattedAddress = "formatted_address"
    }
}

extension FoursquarePlace {
    /// Maps a Foursquare result into a Roamly `Place` for the given intention.
    /// Returns nil if the result lacks coordinates (unroutable).
    func toPlace(intention: Intention) -> Place? {
        guard let coord = geocodes?.main else { return nil }
        let category = categories.first?.name ?? "Local Spot"
        // Foursquare rating is 0–10; Roamly uses 0–5.
        let normalizedRating = rating.map { ($0 / 2.0).rounded(toPlaces: 1) } ?? 4.0
        let iconic = (rating ?? 0) >= 9.0
        return Place(
            id: "fsq-\(fsqID)",
            name: name,
            intentions: [intention == .surpriseMe ? .localClassics : intention],
            coordinate: Coordinate(latitude: coord.latitude, longitude: coord.longitude),
            categoryLabel: category,
            whyItMatters: "A well-rated \(category.lowercased()) worth a stop on your \(intention.title.lowercased()) route.",
            description: "\(name) is a popular \(category.lowercased()) nearby, surfaced live from Foursquare based on your location and the vibe you chose.",
            address: location?.formattedAddress ?? "Address unavailable",
            rating: normalizedRating,
            priceTier: price,
            symbol: intention.symbol,
            suggestedMinutes: 30,
            openingHours: nil,
            insiderTip: nil,
            foodRecommendation: nil,
            isIconic: iconic
        )
    }
}

private extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let factor = pow(10.0, Double(places))
        return (self * factor).rounded() / factor
    }
}
