//
//  AppEnvironment.swift
//  Roamly
//
//  Composition root. Owns the long-lived services and shared stores so that
//  feature view models can be constructed with their dependencies injected.
//

import Foundation
import Combine

/// Top-level app environment / dependency container.
///
/// Keeping construction in one place means we can swap the mock data service
/// for a real networking service later without touching feature code.
@MainActor
final class AppEnvironment: ObservableObject {

    // MARK: Services
    let dataService: PlacesDataProviding
    let locationService: LocationService
    let routeEngine: RouteGenerationService
    let mapService: MapService
    let persistence: PersistenceProviding
    let narrator: RouteNarrating

    // MARK: Shared stores
    let savedTripsStore: SavedTripsStore

    // MARK: Navigation
    /// Whether the user has completed onboarding (persisted).
    @Published var hasCompletedOnboarding: Bool {
        didSet { persistence.setOnboardingComplete(hasCompletedOnboarding) }
    }

    init(
        dataService: PlacesDataProviding,
        locationService: LocationService,
        routeEngine: RouteGenerationService,
        mapService: MapService,
        persistence: PersistenceProviding,
        narrator: RouteNarrating
    ) {
        self.dataService = dataService
        self.locationService = locationService
        self.routeEngine = routeEngine
        self.mapService = mapService
        self.persistence = persistence
        self.narrator = narrator
        self.savedTripsStore = SavedTripsStore(persistence: persistence)
        self.hasCompletedOnboarding = persistence.isOnboardingComplete()
    }

    /// Builds the production composition.
    ///
    /// Defaults to fully offline mock data + on-device persistence, so the app
    /// always works with no configuration. Set `ROAMLY_PLACES_PROVIDER` and the
    /// matching API key to activate live data, or `ANTHROPIC_API_KEY` to enable
    /// AI route narration — no other code changes required.
    static func makeDefault() -> AppEnvironment {
        // Data source: live provider when configured, otherwise bundled mock.
        let data: PlacesDataProviding
        switch RoamlyConfig.placesProvider {
        case .foursquare:
            data = RemotePlacesService()
        case .googlePlaces, .mock:
            // TODO: Add a GooglePlacesService implementation behind the same protocol.
            data = MockDataService()
        }

        // Persistence: UserDefaults by default. `SwiftDataPersistenceService()`
        // is a tested drop-in replacement — swap this one line to adopt it.
        let persistence: PersistenceProviding = UserDefaultsPersistenceService()

        // Narration: AI-backed when a key is present, otherwise local + free.
        let narrator: RouteNarrating = RoamlyConfig.aiNarrationEnabled
            ? AnthropicRouteNarrator()
            : MockRouteNarrator()

        let location = LocationService()
        let engine = RouteGenerationService(dataService: data)
        let map = MapService()
        return AppEnvironment(
            dataService: data,
            locationService: location,
            routeEngine: engine,
            mapService: map,
            persistence: persistence,
            narrator: narrator
        )
    }
}
