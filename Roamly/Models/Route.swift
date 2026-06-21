//
//  Route.swift
//  Roamly
//
//  A generated walking route and its ordered stops.
//

import Foundation

/// The flavor of a generated route option.
enum RouteKind: String, Codable, CaseIterable, Hashable {
    case bestOverall
    case localFavorite
    case efficient

    var title: String {
        switch self {
        case .bestOverall: return "Best Overall"
        case .localFavorite: return "Local Favorite"
        case .efficient: return "Efficient Route"
        }
    }

    var symbol: String {
        switch self {
        case .bestOverall: return "star.circle.fill"
        case .localFavorite: return "heart.circle.fill"
        case .efficient: return "bolt.circle.fill"
        }
    }

    var blurb: String {
        switch self {
        case .bestOverall: return "The iconic highlights, balanced for the time you have."
        case .localFavorite: return "Where locals actually go — a little off the obvious path."
        case .efficient: return "Maximum to see, minimum walking. Tightly routed."
        }
    }
}

struct Route: Codable, Identifiable, Hashable {
    let id: String
    let kind: RouteKind
    let title: String
    let summary: String
    let cityName: String
    let intention: Intention
    let duration: TripDuration
    let stops: [RouteStop]
    /// Total walking distance in meters.
    let totalWalkingMeters: Double
    /// Estimated total experience duration in minutes (walking + time at stops).
    let estimatedMinutes: Int
    let tags: [String]
    /// For multi-day (weekend) itineraries: stop indices grouped by day.
    let dayBreaks: [Int]?
    /// Straight-line distance (meters) from the user's location to the first stop.
    var startDistanceMeters: Double? = nil
    /// Estimated walking minutes from the user's location to the first stop.
    var startWalkingMinutes: Int? = nil

    var stopCount: Int { stops.count }

    // MARK: Formatted helpers
    var walkingDistanceText: String {
        if totalWalkingMeters >= 1000 {
            return String(format: "%.1f km", totalWalkingMeters / 1000)
        }
        return "\(Int(totalWalkingMeters)) m"
    }

    var durationText: String {
        let h = estimatedMinutes / 60
        let m = estimatedMinutes % 60
        if h == 0 { return "\(m) min" }
        if m == 0 { return "\(h) hr" }
        return "\(h) hr \(m) min"
    }

    /// Human-readable "distance from you to the start", e.g. "1.2 km away".
    /// nil when unknown; "At the start" when you're essentially there.
    var startDistanceText: String? {
        guard let meters = startDistanceMeters else { return nil }
        if meters < 120 { return "You're at the start" }
        let distance: String
        if meters >= 1000 {
            distance = String(format: "%.1f km", meters / 1000)
        } else {
            distance = "\(Int((meters / 50).rounded()) * 50) m"
        }
        if let minutes = startWalkingMinutes, meters >= 120 {
            return "\(distance) · ~\(minutes) min to start"
        }
        return "\(distance) to start"
    }
}
