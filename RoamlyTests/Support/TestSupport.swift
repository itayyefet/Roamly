//
//  TestSupport.swift
//  RoamlyTests
//
//  Shared helpers and in-memory fakes for the test suite.
//

import Foundation
@testable import Roamly

/// In-memory `PersistenceProviding` for fast, isolated store tests.
final class InMemoryPersistence: PersistenceProviding {
    var trips: [SavedTrip] = []
    var onboarding = false
    var prefs = UserPreference.default

    func loadSavedTrips() -> [SavedTrip] { trips }
    func saveTrips(_ trips: [SavedTrip]) { self.trips = trips }
    func isOnboardingComplete() -> Bool { onboarding }
    func setOnboardingComplete(_ complete: Bool) { onboarding = complete }
    func loadPreferences() -> UserPreference { prefs }
    func savePreferences(_ preference: UserPreference) { prefs = preference }
}

enum TestFactory {
    /// Builds a real route via the engine for use in store/persistence tests.
    static func sampleRoute(
        city: City = SampleData.rome,
        intention: Intention = .history,
        duration: TripDuration = .mini120
    ) async -> Route {
        let engine = RouteGenerationService(dataService: MockDataService())
        let request = RouteRequest(
            city: city,
            start: city.center,
            intention: intention,
            duration: duration
        )
        let routes = try! await engine.generateRoutes(for: request)
        return routes.first!
    }
}
