//
//  RouteStop.swift
//  Roamly
//
//  A single ordered stop within a route. Wraps a Place with sequencing info.
//

import Foundation

struct RouteStop: Codable, Identifiable, Hashable {
    let id: String
    /// 1-based position in the route.
    let order: Int
    let place: Place
    /// Suggested minutes to spend at this stop.
    let suggestedMinutes: Int
    /// Walking minutes to the next stop (0 for the final stop).
    let walkingMinutesToNext: Int
    /// Walking distance to the next stop in meters (0 for the final stop).
    let walkingMetersToNext: Double
    /// Optional break suggestion attached after this stop (coffee/food/restroom).
    let breakSuggestion: BreakSuggestion?
    /// Which day this stop belongs to (1-based) for multi-day itineraries.
    let day: Int

    var walkingToNextText: String {
        guard walkingMinutesToNext > 0 else { return "Final stop" }
        let dist: String
        if walkingMetersToNext >= 1000 {
            dist = String(format: "%.1f km", walkingMetersToNext / 1000)
        } else {
            dist = "\(Int(walkingMetersToNext)) m"
        }
        return "\(walkingMinutesToNext) min walk · \(dist)"
    }
}

/// A suggested break inserted into longer routes.
struct BreakSuggestion: Codable, Hashable {
    enum Kind: String, Codable {
        case coffee, food, restroom

        var symbol: String {
            switch self {
            case .coffee: return "cup.and.saucer.fill"
            case .food: return "fork.knife"
            case .restroom: return "figure.dress.line.vertical.figure"
            }
        }

        var label: String {
            switch self {
            case .coffee: return "Coffee break"
            case .food: return "Meal break"
            case .restroom: return "Rest stop"
            }
        }
    }

    let kind: Kind
    let text: String
}
