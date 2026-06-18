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
        persistence: PersistenceProviding
    ) {
        self.dataService = dataService
        self.locationService = locationService
        self.routeEngine = routeEngine
        self.mapService = mapService
        self.persistence = persistence
        self.savedTripsStore = SavedTripsStore(persistence: persistence)
        self.hasCompletedOnboarding = persistence.isOnboardingComplete()
    }

    /// Builds the production composition using mock data.
    ///
    /// TODO: When a real backend exists, swap `MockDataService` for a
    /// `RemotePlacesService` that talks to Google Places / Foursquare / a
    /// custom Roamly API. The rest of the app is agnostic to the source.
    static func makeDefault() -> AppEnvironment {
        let data = MockDataService()
        let persistence = UserDefaultsPersistenceService()
        let location = LocationService()
        let engine = RouteGenerationService(dataService: data)
        let map = MapService()
        return AppEnvironment(
            dataService: data,
            locationService: location,
            routeEngine: engine,
            mapService: map,
            persistence: persistence
        )
    }
}
