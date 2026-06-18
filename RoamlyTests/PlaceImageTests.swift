//
//  PlaceImageTests.swift
//  RoamlyTests
//

import XCTest
@testable import Roamly

final class PlaceImageTests: XCTestCase {

    func testParsesThumbnailFromPageImagesResponse() {
        let json = """
        {
          "query": {
            "pages": {
              "12345": {
                "pageid": 12345,
                "title": "Colosseum",
                "thumbnail": {
                  "source": "https://upload.wikimedia.org/wikipedia/commons/thumb/x/colosseum/800px-colosseum.jpg",
                  "width": 800,
                  "height": 600
                }
              }
            }
          }
        }
        """.data(using: .utf8)!

        let url = PlaceImageService.parseThumbnail(from: json)
        XCTAssertEqual(url?.absoluteString,
                       "https://upload.wikimedia.org/wikipedia/commons/thumb/x/colosseum/800px-colosseum.jpg")
    }

    func testReturnsNilWhenNoThumbnail() {
        let json = """
        { "query": { "pages": { "-1": { "title": "Nope", "missing": "" } } } }
        """.data(using: .utf8)!
        XCTAssertNil(PlaceImageService.parseThumbnail(from: json))
    }

    func testEndpointEncodesTitle() throws {
        let url = try XCTUnwrap(PlaceImageService.endpoint(for: "Notre-Dame de Paris"))
        let s = url.absoluteString
        XCTAssertTrue(s.contains("en.wikipedia.org/w/api.php"))
        XCTAssertTrue(s.contains("prop=pageimages"))
        XCTAssertTrue(s.contains("pithumbsize=800"))
        // Spaces must be percent-encoded, not raw.
        XCTAssertFalse(s.contains("Paris "))
    }

    func testCatalogResolvesKnownPlaces() async {
        // Every iconic sample place should have a curated image title.
        for city in SampleData.cities {
            for place in city.places where place.isIconic {
                XCTAssertNotNil(PlaceImageCatalog.title(for: place),
                                "Missing image title for iconic place \(place.id)")
            }
        }
    }

    func testParsesSummaryImageFallback() {
        let json = """
        {
          "title": "Bayfront Park (Miami)",
          "thumbnail": { "source": "https://upload.wikimedia.org/x/200px-bayfront.jpg" },
          "originalimage": { "source": "https://upload.wikimedia.org/x/bayfront.jpg" }
        }
        """.data(using: .utf8)!
        XCTAssertEqual(PlaceImageService.parseSummaryImage(from: json)?.absoluteString,
                       "https://upload.wikimedia.org/x/200px-bayfront.jpg")
    }

    func testSummaryEndpointEncodesTitle() throws {
        let url = try XCTUnwrap(PlaceImageService.summaryEndpoint(for: "Pérez Art Museum Miami"))
        let s = url.absoluteString
        XCTAssertTrue(s.contains("/api/rest_v1/page/summary/"))
        XCTAssertTrue(s.contains("Museum"))
        XCTAssertFalse(s.contains(" "))   // spaces must be encoded/replaced
    }
}
