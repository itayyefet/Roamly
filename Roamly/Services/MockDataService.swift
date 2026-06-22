//
//  MockDataService.swift
//  Roamly
//
//  Local, in-memory implementation of `PlacesDataProviding` backed by the
//  hand-authored sample catalog in `SampleData`.
//
//  TODO: Replace with a `RemotePlacesService` that calls a live API
//  (Google Places, Foursquare, Yelp, TripAdvisor, or a custom backend).
//  Keep the same protocol so no UI/ViewModel code changes.
//

import Foundation

final class MockDataService: PlacesDataProviding {

    private let cities: [City]

    init(cities: [City] = SampleData.cities) {
        self.cities = cities
    }

    func allCities() async -> [City] {
        cities.sorted { $0.name < $1.name }
    }

    func city(withID id: String) async -> City? {
        cities.first { $0.id == id }
    }

    func nearestCity(to coordinate: Coordinate, maxRadiusMeters: Double) async -> City? {
        let ranked = cities
            .map { (city: $0, distance: $0.center.distance(to: coordinate)) }
            .sorted { $0.distance < $1.distance }
        guard let best = ranked.first, best.distance <= maxRadiusMeters else { return nil }
        return best.city
    }

    func places(in city: City, matching intention: Intention) async -> [Place] {
        let matched = city.places.filter { $0.matches(intention) }
        // Relevance: iconic first, then rating.
        return matched.sorted { lhs, rhs in
            if lhs.isIconic != rhs.isIconic { return lhs.isIconic }
            return lhs.rating > rhs.rating
        }
    }
}
