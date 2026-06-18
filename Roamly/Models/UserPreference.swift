//
//  UserPreference.swift
//  Roamly
//
//  Lightweight user preferences, persisted between launches.
//

import Foundation

struct UserPreference: Codable, Hashable {
    enum Units: String, Codable, CaseIterable {
        case metric, imperial
        var title: String { self == .metric ? "Metric (km)" : "Imperial (mi)" }
    }

    enum WalkingPace: String, Codable, CaseIterable {
        case relaxed, balanced, brisk

        var title: String {
            switch self {
            case .relaxed: return "Relaxed"
            case .balanced: return "Balanced"
            case .brisk: return "Brisk"
            }
        }

        /// Walking speed in meters per minute, used by the route engine.
        var metersPerMinute: Double {
            switch self {
            case .relaxed: return 65
            case .balanced: return 80
            case .brisk: return 95
            }
        }
    }

    var units: Units
    var pace: WalkingPace
    /// Intentions the user tends to pick — used to pre-highlight chips.
    var favoriteIntentions: [Intention]
    /// When on, the app uses a demo city instead of real location (great for Simulator).
    var demoModeEnabled: Bool
    /// The manually selected city id, if the user overrode detection.
    var manualCityID: String?

    static let `default` = UserPreference(
        units: .metric,
        pace: .balanced,
        favoriteIntentions: [],
        demoModeEnabled: false,
        manualCityID: nil
    )
}
