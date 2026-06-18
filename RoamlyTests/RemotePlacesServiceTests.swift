//
//  RemotePlacesServiceTests.swift
//  RoamlyTests
//
//  Tests the live-data layer's pure parts: DTO decoding, domain mapping, and
//  the offline-safe behavior of RemotePlacesService (no network involved).
//

import XCTest
@testable import Roamly

final class RemotePlacesServiceTests: XCTestCase {

    private let sampleJSON = """
    {
      "results": [
        {
          "fsq_id": "abc123",
          "name": "Test Cathedral",
          "categories": [{ "name": "Church" }],
          "geocodes": { "main": { "latitude": 41.9, "longitude": 12.5 } },
          "location": { "formatted_address": "1 Test Way, Rome" },
          "rating": 9.2,
          "price": 2
        },
        {
          "fsq_id": "no-geo",
          "name": "Ghost Place",
          "categories": [],
          "rating": 5.0
        }
      ]
    }
    """.data(using: .utf8)!

    func testDecodesAndMapsResults() throws {
        let response = try JSONDecoder().decode(FoursquareSearchResponse.self, from: sampleJSON)
        XCTAssertEqual(response.results.count, 2)

        let places = response.results.compactMap { $0.toPlace(intention: .religiousHeritage) }
        // The second result has no coordinates and must be dropped.
        XCTAssertEqual(places.count, 1)

        let place = places[0]
        XCTAssertEqual(place.id, "fsq-abc123")
        XCTAssertEqual(place.name, "Test Cathedral")
        XCTAssertEqual(place.coordinate.latitude, 41.9, accuracy: 0.0001)
        XCTAssertEqual(place.rating, 4.6, accuracy: 0.01)  // 9.2 / 2, rounded
        XCTAssertTrue(place.isIconic)                       // rating >= 9
        XCTAssertEqual(place.priceTier, 2)
        XCTAssertTrue(place.intentions.contains(.religiousHeritage))
    }

    func testSurpriseMeMapsToLocalClassics() throws {
        let response = try JSONDecoder().decode(FoursquareSearchResponse.self, from: sampleJSON)
        let place = response.results.compactMap { $0.toPlace(intention: .surpriseMe) }.first
        XCTAssertEqual(place?.intentions, [.localClassics])
    }

    func testCityAnchorsHaveNoEmbeddedPlaces() async {
        let service = RemotePlacesService(apiKey: nil)
        let cities = await service.allCities()
        XCTAssertFalse(cities.isEmpty)
        XCTAssertTrue(cities.allSatisfy { $0.places.isEmpty })
    }

    func testMissingKeyFailsSoftToEmptyPlaces() async {
        let service = RemotePlacesService(apiKey: nil)
        let city = SampleData.rome
        let places = await service.places(in: city, matching: .history)
        XCTAssertTrue(places.isEmpty)
    }

    func testNearestCityResolvesFromAnchors() async {
        let service = RemotePlacesService(apiKey: nil)
        let romeish = Coordinate(latitude: 41.9, longitude: 12.49)
        let city = await service.nearestCity(to: romeish)
        XCTAssertEqual(city?.id, "rome")
    }
}
