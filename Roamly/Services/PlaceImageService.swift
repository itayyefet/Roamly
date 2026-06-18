//
//  PlaceImageService.swift
//  Roamly
//
//  Resolves a real photo URL for a place from its Wikipedia article title using
//  the MediaWiki PageImages API (which follows redirects), with an in-memory
//  cache. Failures are remembered so we don't retry a missing image repeatedly.
//
//  This keeps the curated catalog free of brittle, hardcoded image filenames.
//  TODO: For the live Foursquare provider, map photos directly from its API
//  instead of going through Wikipedia.
//

import Foundation

@MainActor
final class PlaceImageService {

    static let shared = PlaceImageService()

    private var cache: [String: URL] = [:]
    private var failed: Set<String> = []
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Returns a photo URL for a Wikipedia article title, or nil if unavailable.
    func imageURL(forTitle title: String) async -> URL? {
        if let cached = cache[title] { return cached }
        if failed.contains(title) { return nil }

        guard let endpoint = Self.endpoint(for: title) else {
            failed.insert(title)
            return nil
        }

        do {
            let (data, response) = try await session.data(from: endpoint)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode),
                  let url = Self.parseThumbnail(from: data) else {
                failed.insert(title)
                return nil
            }
            cache[title] = url
            return url
        } catch {
            failed.insert(title)
            return nil
        }
    }

    // MARK: Helpers

    nonisolated static func endpoint(for title: String) -> URL? {
        var components = URLComponents(string: "https://en.wikipedia.org/w/api.php")
        components?.queryItems = [
            URLQueryItem(name: "action", value: "query"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "prop", value: "pageimages"),
            URLQueryItem(name: "piprop", value: "thumbnail"),
            URLQueryItem(name: "pithumbsize", value: "800"),
            URLQueryItem(name: "redirects", value: "1"),
            URLQueryItem(name: "titles", value: title)
        ]
        return components?.url
    }

    /// Extracts `query.pages.<id>.thumbnail.source` from a PageImages response.
    nonisolated static func parseThumbnail(from data: Data) -> URL? {
        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let query = json["query"] as? [String: Any],
            let pages = query["pages"] as? [String: Any]
        else { return nil }

        for (_, value) in pages {
            if let page = value as? [String: Any],
               let thumbnail = page["thumbnail"] as? [String: Any],
               let source = thumbnail["source"] as? String,
               let url = URL(string: source) {
                return url
            }
        }
        return nil
    }
}
