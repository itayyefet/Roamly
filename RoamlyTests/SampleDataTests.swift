//
//  SampleDataTests.swift
//  RoamlyTests
//
//  Sanity checks on the sample catalog and data provider: city resolution,
//  required cities, and opening-hours logic.
//

import XCTest
import CoreLocation
@testable import Roamly

final class SampleDataTests: XCTestCase {

    func testRequiredCitiesArePresent() {
        let names = Set(SampleData.cities.map(\.name))
        for required in ["Miami", "Copenhagen", "Manhattan"] {
            XCTAssertTrue(names.contains(required), "Expected sample catalog to include \(required)")
        }
    }

    func testEveryCityHasPlacesAcrossCategories() {
        for city in SampleData.cities {
            XCTAssertGreaterThanOrEqual(city.places.count, 5, "\(city.name) should have a useful number of places")
            let categories = Set(city.places.flatMap(\.intentions))
            XCTAssertGreaterThanOrEqual(categories.count, 4, "\(city.name) should span multiple categories")
        }
    }

    func testNearestCityResolvesFromCoordinate() async {
        let data = MockDataService()
        // A coordinate in central Copenhagen should resolve to Copenhagen.
        let nearby = Coordinate(latitude: 55.6761, longitude: 12.5683)
        let city = await data.nearestCity(to: nearby)
        XCTAssertEqual(city?.name, "Copenhagen")
    }

    func testNearestCityReturnsNilWhenFarAway() async {
        let data = MockDataService()
        // Middle of the Pacific — no supported city within range.
        let remote = Coordinate(latitude: 0, longitude: -160)
        let city = await data.nearestCity(to: remote, maxRadiusMeters: 60_000)
        XCTAssertNil(city)
    }

    func testOpeningHoursOvernightWindow() {
        // A nightlife venue open 18:00–02:00.
        let hours = OpeningHours(opensAtHour: 18, closesAtHour: 2, closedWeekdays: [])
        var comps = DateComponents()
        comps.year = 2025; comps.month = 6; comps.day = 18; comps.hour = 23
        let lateNight = Calendar.current.date(from: comps)!
        XCTAssertTrue(hours.isOpen(at: lateNight))

        comps.hour = 10
        let morning = Calendar.current.date(from: comps)!
        XCTAssertFalse(hours.isOpen(at: morning))
    }

    func testClosedWeekdayIsRespected() {
        // Closed on Wednesday (weekday 4).
        let hours = OpeningHours(opensAtHour: 9, closesAtHour: 18, closedWeekdays: [4])
        var comps = DateComponents()
        comps.year = 2025; comps.month = 6; comps.day = 18; comps.hour = 12 // Wednesday
        let wednesday = Calendar.current.date(from: comps)!
        XCTAssertFalse(hours.isOpen(at: wednesday))
    }
}
