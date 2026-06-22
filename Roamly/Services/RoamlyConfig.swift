//
//  RoamlyConfig.swift
//  Roamly
//
//  Central feature/config switches. The defaults keep the app fully functional
//  offline with mock data; flipping a provider (and supplying a key via the
//  environment / an xcconfig) activates live integrations with no other changes.
//
//  IMPORTANT: never hardcode secrets in source. Keys are read from the process
//  environment here for the MVP; wire them through an xcconfig or the keychain
//  for production.
//

import Foundation

enum PlacesProvider: String {
    case mock
    case foursquare
    case googlePlaces
}

enum RoamlyConfig {

    /// Which place data source the app uses. Defaults to the bundled mock.
    static var placesProvider: PlacesProvider {
        if let raw = ProcessInfo.processInfo.environment["ROAMLY_PLACES_PROVIDER"],
           let provider = PlacesProvider(rawValue: raw) {
            return provider
        }
        return .mock
    }

    // MARK: API keys (env-injected; nil/empty disables the integration)

    /// Reads an env var, treating an empty/whitespace value as absent so an
    /// exported-but-blank key (common in CI templates) doesn't look configured.
    private static func key(_ name: String) -> String? {
        guard let value = ProcessInfo.processInfo.environment[name]?
            .trimmingCharacters(in: .whitespacesAndNewlines),
            !value.isEmpty else { return nil }
        return value
    }

    static var foursquareAPIKey: String? { key("FOURSQUARE_API_KEY") }

    static var googlePlacesAPIKey: String? { key("GOOGLE_PLACES_API_KEY") }

    static var anthropicAPIKey: String? { key("ANTHROPIC_API_KEY") }

    /// AI narration is on when a key is present.
    static var aiNarrationEnabled: Bool { anthropicAPIKey != nil }
}
