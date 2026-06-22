//
//  AnthropicRouteNarrator.swift
//  Roamly
//
//  An LLM-backed route narrator using the Anthropic Messages API. This is the
//  seam for "AI-generated personalized city routes / narration" on the roadmap.
//  It degrades gracefully: any failure (no key, offline, rate limit) falls back
//  to the deterministic MockRouteNarrator so the UI never breaks.
//
//  Activate by supplying ANTHROPIC_API_KEY in the environment.
//

import Foundation

struct AnthropicRouteNarrator: RouteNarrating {

    private let apiKey: String?
    private let session: URLSession
    private let fallback = MockRouteNarrator()
    /// Fast, cost-effective model is ideal for short narration.
    private let model = "claude-haiku-4-5-20251001"

    init(apiKey: String? = RoamlyConfig.anthropicAPIKey, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    func narrate(_ route: Route) async -> String {
        guard let apiKey, !apiKey.isEmpty else { return await fallback.narrate(route) }
        do {
            return try await requestNarration(route, apiKey: apiKey)
        } catch {
            return await fallback.narrate(route)
        }
    }

    // MARK: Anthropic Messages API

    private func requestNarration(_ route: Route, apiKey: String) async throws -> String {
        let stopList = route.stops.map { "\($0.order). \($0.place.name) — \($0.place.categoryLabel)" }
            .joined(separator: "\n")
        let prompt = """
        Write a warm, 1–2 sentence intro for a self-guided walking route a traveler is about to start. \
        Be friendly and concrete, not flowery. City: \(route.cityName). Vibe: \(route.intention.title). \
        Total: \(route.durationText), \(route.stopCount) stops, \(route.walkingDistanceText) walking.
        Stops:
        \(stopList)
        """

        var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "content-type")

        let body: [String: Any] = [
            "model": model,
            "max_tokens": 120,
            "messages": [["role": "user", "content": prompt]]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try Self.parseText(from: data)
    }

    /// Extracts the first text block from an Anthropic Messages response.
    static func parseText(from data: Data) throws -> String {
        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let content = json["content"] as? [[String: Any]],
            let text = content.first(where: { ($0["type"] as? String) == "text" })?["text"] as? String
        else {
            throw URLError(.cannotParseResponse)
        }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
