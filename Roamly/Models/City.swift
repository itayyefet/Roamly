//
//  City.swift
//  Roamly
//
//  A city with its catalog of places. Used by the mock data engine and the
//  manual city-selection fallback.
//

import Foundation

struct City: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let country: String
    let countryFlag: String
    let center: Coordinate
    /// Optional neighborhoods for nicer "city + neighborhood" display.
    let neighborhoods: [Neighborhood]
    let places: [Place]

    var displayName: String { "\(name), \(country)" }

    /// Returns the nearest neighborhood name to a coordinate, if any.
    func nearestNeighborhood(to coordinate: Coordinate) -> String? {
        neighborhoods
            .min { $0.center.distance(to: coordinate) < $1.center.distance(to: coordinate) }?
            .name
    }
}

struct Neighborhood: Codable, Hashable {
    let name: String
    let center: Coordinate
}
