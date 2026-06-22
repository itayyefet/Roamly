//
//  NarratorAndPersistenceTests.swift
//  RoamlyTests
//
//  Covers the AI narration seam (mock + Anthropic response parsing) and the
//  SwiftData persistence implementation (in-memory round trips).
//

import XCTest
@testable import Roamly

final class NarratorTests: XCTestCase {

    func testMockNarratorProducesFriendlyNote() async {
        let route = await TestFactory.sampleRoute(city: SampleData.rome)
        let note = await MockRouteNarrator().narrate(route)
        XCTAssertFalse(note.isEmpty)
        XCTAssertTrue(note.contains("Rome"))
        XCTAssertTrue(note.contains("\(route.stopCount)"))
    }

    func testAnthropicNarratorFallsBackWithoutKey() async {
        // No key configured -> falls back to deterministic local narration.
        let route = await TestFactory.sampleRoute()
        let narrator = AnthropicRouteNarrator(apiKey: nil)
        let note = await narrator.narrate(route)
        XCTAssertFalse(note.isEmpty)
    }

    func testAnthropicResponseParsing() throws {
        let json = """
        { "content": [ { "type": "text", "text": "  A lovely walk awaits.  " } ] }
        """.data(using: .utf8)!
        let text = try AnthropicRouteNarrator.parseText(from: json)
        XCTAssertEqual(text, "A lovely walk awaits.")
    }
}

final class SwiftDataPersistenceServiceTests: XCTestCase {

    func testSavedTripRoundTrip() async {
        let service = SwiftDataPersistenceService(inMemory: true)
        let route = await TestFactory.sampleRoute()
        let trip = SavedTrip(route: route, isFavorite: true)

        service.saveTrips([trip])
        let loaded = service.loadSavedTrips()

        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.id, trip.id)
        XCTAssertEqual(loaded.first?.route.id, route.id)
        XCTAssertEqual(loaded.first?.isFavorite, true)
    }

    func testReplacingTripsClearsPrevious() async {
        let service = SwiftDataPersistenceService(inMemory: true)
        let route = await TestFactory.sampleRoute()
        service.saveTrips([SavedTrip(route: route)])
        service.saveTrips([])
        XCTAssertTrue(service.loadSavedTrips().isEmpty)
    }

    func testPreferencesAndOnboardingPersist() {
        // Use an isolated UserDefaults suite to avoid polluting the device.
        let defaults = UserDefaults(suiteName: "roamly.tests.\(UUID().uuidString)")!
        let service = SwiftDataPersistenceService(inMemory: true, defaults: defaults)

        XCTAssertFalse(service.isOnboardingComplete())
        service.setOnboardingComplete(true)
        XCTAssertTrue(service.isOnboardingComplete())

        var prefs = UserPreference.default
        prefs.pace = .brisk
        service.savePreferences(prefs)
        XCTAssertEqual(service.loadPreferences().pace, .brisk)
    }
}
