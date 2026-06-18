//
//  SwiftDataPersistenceService.swift
//  Roamly
//
//  A SwiftData-backed implementation of `PersistenceProviding`. Saved trips are
//  stored as SwiftData records (with the full trip encoded as a payload for
//  forward-compatibility); lightweight flags stay in UserDefaults.
//
//  This is a drop-in replacement for `UserDefaultsPersistenceService` — flip the
//  one line in `AppEnvironment.makeDefault()` to adopt it. Kept behind the same
//  protocol so nothing else in the app needs to change.
//

import Foundation
import SwiftData

/// SwiftData record for a saved trip. The full `SavedTrip` is stored as an
/// encoded payload so the schema is resilient to model changes.
@Model
final class SavedTripRecord {
    @Attribute(.unique) var id: String
    var savedAt: Date
    var isFavorite: Bool
    var payload: Data

    init(id: String, savedAt: Date, isFavorite: Bool, payload: Data) {
        self.id = id
        self.savedAt = savedAt
        self.isFavorite = isFavorite
        self.payload = payload
    }
}

final class SwiftDataPersistenceService: PersistenceProviding {

    private let container: ModelContainer
    private let context: ModelContext
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private enum Key {
        static let onboarding = "roamly.onboardingComplete"
        static let preferences = "roamly.preferences"
    }

    /// - Parameter inMemory: pass true for tests / previews (no disk writes).
    init(inMemory: Bool = false, defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        // Force-try is acceptable here: a failure to build the local store is a
        // programmer error (bad schema), not a recoverable runtime condition.
        self.container = try! ModelContainer(for: SavedTripRecord.self, configurations: configuration)
        self.context = ModelContext(container)
    }

    // MARK: Saved trips

    func loadSavedTrips() -> [SavedTrip] {
        let descriptor = FetchDescriptor<SavedTripRecord>(
            sortBy: [SortDescriptor(\.savedAt, order: .reverse)]
        )
        guard let records = try? context.fetch(descriptor) else { return [] }
        return records.compactMap { try? decoder.decode(SavedTrip.self, from: $0.payload) }
    }

    func saveTrips(_ trips: [SavedTrip]) {
        // Simplest correct strategy: replace the full set.
        if let existing = try? context.fetch(FetchDescriptor<SavedTripRecord>()) {
            for record in existing { context.delete(record) }
        }
        for trip in trips {
            guard let payload = try? encoder.encode(trip) else { continue }
            context.insert(SavedTripRecord(
                id: trip.id,
                savedAt: trip.savedAt,
                isFavorite: trip.isFavorite,
                payload: payload
            ))
        }
        try? context.save()
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
