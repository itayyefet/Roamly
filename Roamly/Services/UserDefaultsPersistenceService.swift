//
//  UserDefaultsPersistenceService.swift
//  Roamly
//
//  Concrete persistence using UserDefaults with JSON-encoded payloads.
//

import Foundation

final class UserDefaultsPersistenceService: PersistenceProviding {

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private enum Key {
        static let savedTrips = "roamly.savedTrips"
        static let onboarding = "roamly.onboardingComplete"
        static let preferences = "roamly.preferences"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: Saved trips
    func loadSavedTrips() -> [SavedTrip] {
        guard let data = defaults.data(forKey: Key.savedTrips),
              let trips = try? decoder.decode([SavedTrip].self, from: data) else {
            return []
        }
        return trips
    }

    func saveTrips(_ trips: [SavedTrip]) {
        guard let data = try? encoder.encode(trips) else { return }
        defaults.set(data, forKey: Key.savedTrips)
    }

    // MARK: Onboarding
    func isOnboardingComplete() -> Bool {
        defaults.bool(forKey: Key.onboarding)
    }

    func setOnboardingComplete(_ complete: Bool) {
        defaults.set(complete, forKey: Key.onboarding)
    }

    // MARK: Preferences
    func loadPreferences() -> UserPreference {
        guard let data = defaults.data(forKey: Key.preferences),
              let prefs = try? decoder.decode(UserPreference.self, from: data) else {
            return .default
        }
        return prefs
    }

    func savePreferences(_ preference: UserPreference) {
        guard let data = try? encoder.encode(preference) else { return }
        defaults.set(data, forKey: Key.preferences)
    }
}
