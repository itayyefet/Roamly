//
//  PlaceImageService.swift
//  Roamly
//
//  Resolves a real photo URL for a place from its Wikipedia article title.
//  Tries the MediaWiki PageImages API first, then the REST summary endpoint as
//  a fallback, with an in-memory cache and negative caching of misses.
//
//  Wikimedia requires a descriptive User-Agent, so every request sends one.
//  TODO: For the live Foursquare provider, map photos directly from its API.
//

import Foundation

@MainActor
final class PlaceImageService {

    static let shared = PlaceImageService()

    private var cache: [String: URL] = [:]
    private var failed: Set<String> = []
    private let session: URLSession

    /// Wikimedia's UA policy asks clients to identify themselves.
    private let userAgent = "Roamly/1.0 (https://github.com/itayyefet/Roamly; contact: yefet.itay@gmail.com)"

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Returns a photo URL for a Wikipedia article title, or nil if unavailable.
    func imageURL(forTitle title: String) async -> URL? {
        if let cached = cache[title] { return cached }
        if failed.contains(title) { return nil }

        if let url = await pageImageURL(forTitle: title) ?? summaryImageURL(forTitle: title) {
            cache[title] = url
            return url
        }
        failed.insert(title)
        return nil
    }

    // MARK: Sources

    private func pageImageURL(forTitle title: String) async -> URL? {
        guard let endpoint = Self.endpoint(for: title) else { return nil }
        guard let data = try? await fetch(endpoint) else { return nil }
        return Self.parseThumbnail(from: data)
    }

    private func summaryImageURL(forTitle title: String) async -> URL? {
        guard let endpoint = Self.summaryEndpoint(for: title) else { return nil }
        guard let data = try? await fetch(endpoint) else { return nil }
        return Self.parseSummaryImage(from: data)
    }

    private func fetch(_ url: URL) async throws -> Data? {
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            return nil
        }
        return data
    }

    // MARK: Endpoints

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

    nonisolated static func summaryEndpoint(for title: String) -> URL? {
        let pathTitle = title.replacingOccurrences(of: " ", with: "_")
        guard let encoded = pathTitle.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return nil
        }
        return URL(string: "https://en.wikipedia.org/api/rest_v1/page/summary/\(encoded)")
    }

    // MARK: Parsing

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

    /// Extracts a thumbnail/original image from a REST summary response.
    nonisolated static func parseSummaryImage(from data: Data) -> URL? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        if let thumb = json["thumbnail"] as? [String: Any],
           let source = thumb["source"] as? String,
           let url = URL(string: source) {
            return url
        }
        if let original = json["originalimage"] as? [String: Any],
           let source = original["source"] as? String,
           let url = URL(string: source) {
            return url
        }
        return nil
    }
}
