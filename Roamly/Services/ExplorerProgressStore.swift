//
//  ExplorerProgressStore.swift
//  Roamly
//
//  Tracks the playful "explorer" layer: places you've checked into, cities
//  you've explored, and trips you've completed — plus the badges those unlock.
//  Persisted independently (UserDefaults + JSON) so it stays decoupled from the
//  saved-trips persistence.
//

import Foundation
import Combine

struct ExplorerProgress: Codable, Equatable {
    var visitedPlaceIDs: Set<String> = []
    var completedTripIDs: Set<String> = []
    var visitedCityNames: Set<String> = []
}

@MainActor
final class ExplorerProgressStore: ObservableObject {

    @Published private(set) var progress: ExplorerProgress

    private let defaults: UserDefaults
    private let key = "roamly.explorerProgress"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: key),
           let decoded = try? JSONDecoder().decode(ExplorerProgress.self, from: data) {
            self.progress = decoded
        } else {
            self.progress = ExplorerProgress()
        }
    }

    // MARK: Stats
    var placesVisited: Int { progress.visitedPlaceIDs.count }
    var citiesExplored: Int { progress.visitedCityNames.count }
    var tripsCompleted: Int { progress.completedTripIDs.count }

    func isVisited(_ placeID: String) -> Bool {
        progress.visitedPlaceIDs.contains(placeID)
    }

    // MARK: Mutations

    /// Checks into a place. Returns true if it was newly visited.
    @discardableResult
    func checkIn(place: Place, cityName: String) -> Bool {
        let isNew = !progress.visitedPlaceIDs.contains(place.id)
        progress.visitedPlaceIDs.insert(place.id)
        progress.visitedCityNames.insert(cityName)
        persist()
        return isNew
    }

    func toggleCheckIn(place: Place, cityName: String) {
        if progress.visitedPlaceIDs.contains(place.id) {
            progress.visitedPlaceIDs.remove(place.id)
        } else {
            progress.visitedPlaceIDs.insert(place.id)
            progress.visitedCityNames.insert(cityName)
        }
        persist()
    }

    /// Marks a whole route as completed (all stops visited).
    func completeTrip(_ route: Route) {
        progress.completedTripIDs.insert(route.id)
        progress.visitedCityNames.insert(route.cityName)
        for stop in route.stops {
            progress.visitedPlaceIDs.insert(stop.place.id)
        }
        persist()
    }

    func visitedCount(in route: Route) -> Int {
        route.stops.filter { progress.visitedPlaceIDs.contains($0.place.id) }.count
    }

    func reset() {
        progress = ExplorerProgress()
        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(progress) {
            defaults.set(data, forKey: key)
        }
    }

    // MARK: Badges
    var badges: [Badge] {
        [
            Badge(id: "first-steps", title: "First Steps",
                  detail: "Check into your first stop", symbol: "shoe.fill",
                  isEarned: placesVisited >= 1),
            Badge(id: "explorer", title: "Explorer",
                  detail: "Visit 10 places", symbol: "binoculars.fill",
                  isEarned: placesVisited >= 10),
            Badge(id: "wanderer", title: "Wanderer",
                  detail: "Visit 25 places", symbol: "map.fill",
                  isEarned: placesVisited >= 25),
            Badge(id: "first-trip", title: "Trailblazer",
                  detail: "Finish your first route", symbol: "flag.checkered",
                  isEarned: tripsCompleted >= 1),
            Badge(id: "trip-pro", title: "Globetrotter",
                  detail: "Finish 5 routes", symbol: "airplane",
                  isEarned: tripsCompleted >= 5),
            Badge(id: "city-hopper", title: "City Hopper",
                  detail: "Explore 3 different cities", symbol: "building.2.fill",
                  isEarned: citiesExplored >= 3)
        ]
    }

    var earnedBadgeCount: Int { badges.filter(\.isEarned).count }
}

struct Badge: Identifiable {
    let id: String
    let title: String
    let detail: String
    let symbol: String
    var isEarned: Bool = false
}
