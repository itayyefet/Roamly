//
//  ExplorerProgressStoreTests.swift
//  RoamlyTests
//

import XCTest
@testable import Roamly

@MainActor
final class ExplorerProgressStoreTests: XCTestCase {

    private func makeStore() -> (ExplorerProgressStore, UserDefaults) {
        let defaults = UserDefaults(suiteName: "roamly.explorer.\(UUID().uuidString)")!
        return (ExplorerProgressStore(defaults: defaults), defaults)
    }

    func testCheckInTracksPlacesAndCities() async {
        let (store, _) = makeStore()
        let route = await TestFactory.sampleRoute(city: SampleData.rome)
        let stop = route.stops[0]

        XCTAssertFalse(store.isVisited(stop.place.id))
        let isNew = store.checkIn(place: stop.place, cityName: route.cityName)

        XCTAssertTrue(isNew)
        XCTAssertTrue(store.isVisited(stop.place.id))
        XCTAssertEqual(store.placesVisited, 1)
        XCTAssertEqual(store.citiesExplored, 1)
    }

    func testToggleCheckIn() async {
        let (store, _) = makeStore()
        let route = await TestFactory.sampleRoute()
        let stop = route.stops[0]
        store.toggleCheckIn(place: stop.place, cityName: route.cityName)
        XCTAssertTrue(store.isVisited(stop.place.id))
        store.toggleCheckIn(place: stop.place, cityName: route.cityName)
        XCTAssertFalse(store.isVisited(stop.place.id))
    }

    func testCompleteTripMarksAllStopsAndUnlocksBadges() async {
        let (store, _) = makeStore()
        let route = await TestFactory.sampleRoute()

        store.completeTrip(route)

        XCTAssertEqual(store.visitedCount(in: route), route.stopCount)
        XCTAssertEqual(store.tripsCompleted, 1)
        XCTAssertTrue(store.badges.first { $0.id == "first-steps" }?.isEarned == true)
        XCTAssertTrue(store.badges.first { $0.id == "first-trip" }?.isEarned == true)
    }

    func testBadgesStartLocked() {
        let (store, _) = makeStore()
        XCTAssertEqual(store.earnedBadgeCount, 0)
        XCTAssertTrue(store.badges.allSatisfy { !$0.isEarned })
    }

    func testResetClearsEverything() async {
        let (store, _) = makeStore()
        let route = await TestFactory.sampleRoute()
        store.completeTrip(route)
        store.reset()
        XCTAssertEqual(store.placesVisited, 0)
        XCTAssertEqual(store.tripsCompleted, 0)
        XCTAssertEqual(store.citiesExplored, 0)
    }

    func testProgressPersistsAcrossInstances() async {
        let defaults = UserDefaults(suiteName: "roamly.explorer.\(UUID().uuidString)")!
        let store = ExplorerProgressStore(defaults: defaults)
        let route = await TestFactory.sampleRoute()
        store.completeTrip(route)

        let reloaded = ExplorerProgressStore(defaults: defaults)
        XCTAssertEqual(reloaded.tripsCompleted, 1)
        XCTAssertEqual(reloaded.visitedCount(in: route), route.stopCount)
    }
}
