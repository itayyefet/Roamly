//
//  PlacesDataProviding.swift
//  Roamly
//
//  Abstraction over the source of city & place data. The MVP ships a mock
//  implementation; a future implementation can hit Google Places / Foursquare
//  / a custom Roamly backend without changing any callers.
//

import Foundation

protocol PlacesDataProviding {
    /// All cities available to the app.
    func allCities() async -> [City]

    /// Look up a city by its stable id.
    func city(withID id: String) async -> City?

    /// The nearest city to a coordinate (used to resolve detected location).
    /// Returns nil if no city is within a reasonable radius.
    func nearestCity(to coordinate: Coordinate, maxRadiusMeters: Double) async -> City?

    /// Places in a city that match an intention, sorted by relevance.
    func places(in city: City, matching intention: Intention) async -> [Place]
}

extension PlacesDataProviding {
    func nearestCity(to coordinate: Coordinate) async -> City? {
        await nearestCity(to: coordinate, maxRadiusMeters: 60_000)
    }
}
