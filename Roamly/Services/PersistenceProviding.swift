//
//  PersistenceProviding.swift
//  Roamly
//
//  Persistence abstraction. The MVP uses UserDefaults + JSON encoding, which
//  keeps the surface tiny and replaceable. A future implementation can move to
//  SwiftData or a synced backend behind this same protocol.
//

import Foundation

protocol PersistenceProviding: AnyObject {
    // Saved trips
    func loadSavedTrips() -> [SavedTrip]
    func saveTrips(_ trips: [SavedTrip])

    // Onboarding
    func isOnboardingComplete() -> Bool
    func setOnboardingComplete(_ complete: Bool)

    // Preferences
    func loadPreferences() -> UserPreference
    func savePreferences(_ preference: UserPreference)
}

/// A persisted trip: a generated route plus metadata.
struct SavedTrip: Codable, Identifiable, Hashable {
    let id: String
    let route: Route
    let savedAt: Date
    var isFavorite: Bool

    init(route: Route, savedAt: Date = Date(), isFavorite: Bool = false) {
        self.id = route.id + "-" + String(Int(savedAt.timeIntervalSince1970))
        self.route = route
        self.savedAt = savedAt
        self.isFavorite = isFavorite
    }
}
