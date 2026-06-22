//
//  TripDuration.swift
//  Roamly
//
//  Time-based trip modes that shape how many stops a route contains.
//

import Foundation

enum TripDuration: String, Codable, CaseIterable, Identifiable, Hashable {
    case quick30        // 30-minute quick walk
    case express60      // 1-hour express route
    case mini120        // 2-hour mini tour
    case half240        // 4-hour half-day experience
    case fullDay        // Full-day city plan
    case weekend        // Weekend itinerary

    var id: String { rawValue }

    var title: String {
        switch self {
        case .quick30: return "Quick Walk"
        case .express60: return "Express"
        case .mini120: return "Mini Tour"
        case .half240: return "Half Day"
        case .fullDay: return "Full Day"
        case .weekend: return "Weekend"
        }
    }

    /// Short label used on chips, e.g. "30 min".
    var shortLabel: String {
        switch self {
        case .quick30: return "30 min"
        case .express60: return "1 hr"
        case .mini120: return "2 hrs"
        case .half240: return "4 hrs"
        case .fullDay: return "Full day"
        case .weekend: return "Weekend"
        }
    }

    var symbol: String {
        switch self {
        case .quick30: return "hare.fill"
        case .express60: return "bolt.fill"
        case .mini120: return "figure.walk"
        case .half240: return "sun.max.fill"
        case .fullDay: return "calendar"
        case .weekend: return "calendar.badge.clock"
        }
    }

    /// Approximate total budget in minutes (used by the route engine).
    var totalMinutes: Int {
        switch self {
        case .quick30: return 30
        case .express60: return 60
        case .mini120: return 120
        case .half240: return 240
        case .fullDay: return 480
        case .weekend: return 480 * 2   // structured across two days
        }
    }

    /// The target number of stops for this duration (min, max).
    var stopRange: ClosedRange<Int> {
        switch self {
        case .quick30: return 1...2
        case .express60: return 2...3
        case .mini120: return 3...4
        case .half240: return 4...6
        case .fullDay: return 6...9
        case .weekend: return 8...14
        }
    }

    /// Whether routes of this length should include a meal/coffee break.
    var includesMealBreak: Bool {
        switch self {
        case .quick30, .express60: return false
        case .mini120: return false
        case .half240, .fullDay, .weekend: return true
        }
    }

    /// Multi-day itineraries are structured differently in the UI.
    var isMultiDay: Bool { self == .weekend }
}
