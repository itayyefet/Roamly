//
//  HomeViewModel.swift
//  Roamly
//
//  Drives the Home screen: resolves the current city from location (with demo
//  and manual fallbacks), surfaces nearby highlights, and holds the user's
//  intention/time selection used to build a route query.
//

import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {

    // Resolved context
    @Published private(set) var city: City?
    @Published private(set) var neighborhood: String?
    @Published private(set) var start: Coordinate?
    @Published private(set) var nearbyHighlights: [Place] = []
    @Published private(set) var isResolving = true
    @Published private(set) var locationDenied = false
    /// True when we fell back to a demo/approximate location.
    @Published private(set) var usingApproximateLocation = false

    // User selection
    @Published var selectedIntention: Intention?
    @Published var selectedDuration: TripDuration = .express60

    private var env: AppEnvironment?
    private var location: LocationService?
    private var cancellables = Set<AnyCancellable>()

    var canCreateRoute: Bool { selectedIntention != nil && start != nil && city != nil }

    var greetingCityText: String {
        guard let city else { return "Finding your city…" }
        if let neighborhood { return "\(neighborhood), \(city.name)" }
        return city.displayName
    }

    func configure(env: AppEnvironment, location: LocationService) {
        guard self.env == nil else { return }
        self.env = env
        self.location = location

        // React to live coordinate updates from CoreLocation.
        location.$coordinate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coord in
                guard let self, let coord else { return }
                Task { await self.resolve(using: coord) }
            }
            .store(in: &cancellables)

        location.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self, let location = self.location else { return }
                self.locationDenied = location.isDenied
            }
            .store(in: &cancellables)
    }

    /// Kicks off location resolution, applying preferences and fallbacks.
    func start() async {
        guard let env, let location else { return }
        let prefs = env.persistence.loadPreferences()

        // Pre-select the user's favorite intention if they have one.
        if selectedIntention == nil, let fav = prefs.favoriteIntentions.first {
            selectedIntention = fav
        }

        // Manual city override always wins.
        if let manualID = prefs.manualCityID,
           let manualCity = await env.dataService.city(withID: manualID) {
            applyCity(manualCity, coordinate: manualCity.center, approximate: false)
            return
        }

        // Demo mode (or Simulator convenience): use the demo city.
        if prefs.demoModeEnabled {
            useDemoCity()
            return
        }

        if location.isAuthorized {
            location.requestLocation()
            if let coord = location.coordinate {
                await resolve(using: coord)
            } else {
                // Show an approximate demo city immediately so the screen is
                // never stuck "Finding your city…" if a fix is slow or fails;
                // the $coordinate sink upgrades to the real city once it arrives.
                useDemoCity()
            }
        } else if location.isDenied {
            locationDenied = true
            useDemoCity()
        } else {
            // Permission not yet decided — ask, then fall back to demo meanwhile.
            location.requestPermission()
            useDemoCity()
        }
    }

    func selectIntention(_ intention: Intention) {
        selectedIntention = (selectedIntention == intention) ? nil : intention
    }

    /// Lets the user pick a city manually (fallback flow).
    func selectCity(_ city: City) async {
        applyCity(city, coordinate: city.center, approximate: true)
        // Persist the manual choice.
        if let env {
            var prefs = env.persistence.loadPreferences()
            prefs.manualCityID = city.id
            env.persistence.savePreferences(prefs)
        }
    }

    /// Builds the query for the current selection.
    func makeQuery(forIntention intention: Intention) -> RouteQuery? {
        guard let city, let start else { return nil }
        let pace = env?.persistence.loadPreferences().pace ?? .balanced
        return RouteQuery(
            city: city,
            start: start,
            intention: intention,
            duration: selectedDuration,
            pace: pace
        )
    }

    // MARK: - Resolution helpers

    private func resolve(using coordinate: Coordinate) async {
        guard let env else { return }
        isResolving = true
        if let nearest = await env.dataService.nearestCity(to: coordinate) {
            applyCity(nearest, coordinate: coordinate, approximate: false)
        } else {
            // No supported city nearby — fall back to demo so the app stays useful.
            useDemoCity()
        }
    }

    private func useDemoCity() {
        let demo = SampleData.demoCity
        applyCity(demo, coordinate: demo.center, approximate: true)
    }

    private func applyCity(_ city: City, coordinate: Coordinate, approximate: Bool) {
        self.city = city
        self.start = coordinate
        self.neighborhood = city.nearestNeighborhood(to: coordinate)
        self.usingApproximateLocation = approximate
        self.nearbyHighlights = Array(
            city.places
                .sorted { $0.coordinate.distance(to: coordinate) < $1.coordinate.distance(to: coordinate) }
                .prefix(6)
        )
        self.isResolving = false
    }
}
