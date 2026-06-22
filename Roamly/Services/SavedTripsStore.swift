//
//  SavedTripsStore.swift
//  Roamly
//
//  Observable store for saved trips, backed by the persistence layer.
//

import Foundation
import Combine

@MainActor
final class SavedTripsStore: ObservableObject {

    @Published private(set) var trips: [SavedTrip] = []

    private let persistence: PersistenceProviding

    init(persistence: PersistenceProviding) {
        self.persistence = persistence
        self.trips = persistence.loadSavedTrips()
            .sorted { $0.savedAt > $1.savedAt }
    }

    var favorites: [SavedTrip] {
        trips.filter(\.isFavorite)
    }

    func isSaved(routeID: String) -> Bool {
        trips.contains { $0.route.id == routeID }
    }

    /// Saves a route (no-op if an identical route is already saved).
    @discardableResult
    func save(_ route: Route, favorite: Bool = false) -> SavedTrip {
        if let existing = trips.first(where: { $0.route.id == route.id }) {
            return existing
        }
        let trip = SavedTrip(route: route, isFavorite: favorite)
        trips.insert(trip, at: 0)
        persist()
        return trip
    }

    func toggleSave(_ route: Route) {
        if let index = trips.firstIndex(where: { $0.route.id == route.id }) {
            trips.remove(at: index)
        } else {
            trips.insert(SavedTrip(route: route), at: 0)
        }
        persist()
    }

    func toggleFavorite(_ trip: SavedTrip) {
        guard let index = trips.firstIndex(where: { $0.id == trip.id }) else { return }
        trips[index].isFavorite.toggle()
        persist()
    }

    func delete(_ trip: SavedTrip) {
        trips.removeAll { $0.id == trip.id }
        persist()
    }

    func delete(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) where trips.indices.contains(index) {
            trips.remove(at: index)
        }
        persist()
    }

    private func persist() {
        persistence.saveTrips(trips)
    }
}
