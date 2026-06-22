//
//  SavedTripsStoreTests.swift
//  RoamlyTests
//

import XCTest
@testable import Roamly

@MainActor
final class SavedTripsStoreTests: XCTestCase {

    func testSavePersistsAndSurvivesReload() async {
        let persistence = InMemoryPersistence()
        let store = SavedTripsStore(persistence: persistence)
        let route = await TestFactory.sampleRoute()

        store.save(route)

        XCTAssertTrue(store.isSaved(routeID: route.id))
        XCTAssertEqual(persistence.trips.count, 1)

        // A fresh store reading the same persistence should see the trip.
        let reloaded = SavedTripsStore(persistence: persistence)
        XCTAssertTrue(reloaded.isSaved(routeID: route.id))
    }

    func testSaveIsIdempotent() async {
        let store = SavedTripsStore(persistence: InMemoryPersistence())
        let route = await TestFactory.sampleRoute()
        store.save(route)
        store.save(route)
        XCTAssertEqual(store.trips.count, 1)
    }

    func testToggleSaveRemoves() async {
        let store = SavedTripsStore(persistence: InMemoryPersistence())
        let route = await TestFactory.sampleRoute()
        store.toggleSave(route)
        XCTAssertTrue(store.isSaved(routeID: route.id))
        store.toggleSave(route)
        XCTAssertFalse(store.isSaved(routeID: route.id))
    }

    func testFavoriteToggle() async {
        let store = SavedTripsStore(persistence: InMemoryPersistence())
        let route = await TestFactory.sampleRoute()
        let trip = store.save(route)
        XCTAssertTrue(store.favorites.isEmpty)
        store.toggleFavorite(trip)
        XCTAssertEqual(store.favorites.count, 1)
    }

    func testDelete() async {
        let store = SavedTripsStore(persistence: InMemoryPersistence())
        let route = await TestFactory.sampleRoute()
        let trip = store.save(route)
        store.delete(trip)
        XCTAssertTrue(store.trips.isEmpty)
    }
}
