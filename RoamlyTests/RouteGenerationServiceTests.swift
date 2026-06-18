//
//  RouteGenerationServiceTests.swift
//  RoamlyTests
//
//  Unit tests for the route engine — the app's "brain". These exercise stop
//  scaling, route differentiation, sequencing, breaks, multi-day itineraries
//  and error handling against the curated sample catalog.
//

import XCTest
@testable import Roamly

final class RouteGenerationServiceTests: XCTestCase {

    private var engine: RouteGenerationService!
    private var data: MockDataService!

    override func setUp() {
        super.setUp()
        data = MockDataService()
        engine = RouteGenerationService(dataService: data)
    }

    override func tearDown() {
        engine = nil
        data = nil
        super.tearDown()
    }

    // MARK: Helpers

    /// A Wednesday at 12:00 — keeps most sample places "open" for determinism.
    private func noonWeekday() -> Date {
        var comps = DateComponents()
        comps.year = 2025
        comps.month = 6
        comps.day = 18      // 2025-06-18 is a Wednesday
        comps.hour = 12
        return Calendar.current.date(from: comps) ?? Date()
    }

    private func request(_ city: City,
                         _ intention: Intention,
                         _ duration: TripDuration) -> RouteRequest {
        RouteRequest(
            city: city,
            start: city.center,
            intention: intention,
            duration: duration,
            preference: .default,
            date: noonWeekday()
        )
    }

    // MARK: Tests

    func testGeneratesThreeDistinctRouteKinds() async throws {
        let routes = try await engine.generateRoutes(for: request(SampleData.rome, .history, .mini120))
        XCTAssertEqual(routes.count, 3)
        XCTAssertEqual(Set(routes.map(\.kind)), Set(RouteKind.allCases))
    }

    func testEveryRouteHasAtLeastOneStop() async throws {
        let routes = try await engine.generateRoutes(for: request(SampleData.paris, .artCulture, .express60))
        for route in routes {
            XCTAssertGreaterThanOrEqual(route.stopCount, 1)
            XCTAssertGreaterThan(route.estimatedMinutes, 0)
        }
    }

    func testQuickWalkStaysWithinStopRange() async throws {
        let routes = try await engine.generateRoutes(for: request(SampleData.paris, .architecture, .quick30))
        for route in routes {
            XCTAssertLessThanOrEqual(route.stopCount, TripDuration.quick30.stopRange.upperBound)
        }
    }

    func testLongerDurationProducesMoreStops() async throws {
        let quick = try await engine.generateRoutes(for: request(SampleData.newYork, .surpriseMe, .quick30))
        let fullDay = try await engine.generateRoutes(for: request(SampleData.newYork, .surpriseMe, .fullDay))
        XCTAssertGreaterThan(fullDay[0].stopCount, quick[0].stopCount)
    }

    func testFinalStopHasNoOnwardWalk() async throws {
        let routes = try await engine.generateRoutes(for: request(SampleData.london, .history, .half240))
        for route in routes {
            XCTAssertEqual(route.stops.last?.walkingMinutesToNext, 0)
            XCTAssertEqual(route.stops.last?.walkingMetersToNext, 0)
        }
    }

    func testIntermediateStopsHavePositiveWalkLegs() async throws {
        let routes = try await engine.generateRoutes(for: request(SampleData.london, .surpriseMe, .half240))
        let route = routes[0]
        guard route.stops.count >= 2 else { return }
        for stop in route.stops.dropLast() {
            XCTAssertGreaterThan(stop.walkingMinutesToNext, 0)
        }
    }

    func testHalfDayInsertsABreak() async throws {
        let routes = try await engine.generateRoutes(for: request(SampleData.newYork, .surpriseMe, .half240))
        let anyBreak = routes.contains { $0.stops.contains { $0.breakSuggestion != nil } }
        XCTAssertTrue(anyBreak, "Half-day routes should include at least one coffee/meal break")
    }

    func testWeekendIsMultiDay() async throws {
        let routes = try await engine.generateRoutes(for: request(SampleData.london, .surpriseMe, .weekend))
        let route = routes[0]
        XCTAssertTrue(route.duration.isMultiDay)
        XCTAssertNotNil(route.dayBreaks)
        let distinctDays = Set(route.stops.map(\.day))
        XCTAssertGreaterThanOrEqual(distinctDays.count, 2, "Weekend itineraries should span multiple days")
    }

    func testSurpriseMeIsCategoryDiverse() async throws {
        let routes = try await engine.generateRoutes(for: request(SampleData.rome, .surpriseMe, .half240))
        let intentions = Set(routes[0].stops.flatMap(\.place.intentions))
        XCTAssertGreaterThan(intentions.count, 1, "Surprise Me should mix multiple categories")
    }

    func testEfficientRouteStartsCloserThanBestOverall() async throws {
        let city = SampleData.newYork
        let routes = try await engine.generateRoutes(for: request(city, .surpriseMe, .mini120))
        let best = routes.first { $0.kind == .bestOverall }!
        let efficient = routes.first { $0.kind == .efficient }!
        // The efficient strategy selects the closest cluster to the start, so its
        // first stop is never farther from the start than Best Overall's.
        let effDist = efficient.stops[0].place.coordinate.distance(to: city.center)
        let bestDist = best.stops[0].place.coordinate.distance(to: city.center)
        XCTAssertLessThanOrEqual(effDist, bestDist + 1)
    }

    func testStopsAreSequentiallyNumbered() async throws {
        let routes = try await engine.generateRoutes(for: request(SampleData.paris, .surpriseMe, .half240))
        for route in routes {
            XCTAssertEqual(route.stops.map(\.order), Array(1...route.stopCount))
        }
    }

    func testEmptyCityThrows() async {
        let empty = City(
            id: "empty",
            name: "Nowhere",
            country: "—",
            countryFlag: "🏳️",
            center: Coordinate(latitude: 0, longitude: 0),
            neighborhoods: [],
            places: []
        )
        let fakeEngine = RouteGenerationService(dataService: MockDataService(cities: [empty]))
        do {
            _ = try await fakeEngine.generateRoutes(
                for: RouteRequest(city: empty, start: empty.center, intention: .history, duration: .quick30)
            )
            XCTFail("Expected RouteGenerationError to be thrown for a city with no places")
        } catch {
            XCTAssertTrue(error is RouteGenerationError)
        }
    }
}
