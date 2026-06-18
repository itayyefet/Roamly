//
//  Place.swift
//  Roamly
//
//  A single point of interest. Sample data carries rich, realistic detail so
//  the UI never looks like a prototype. Designed to map cleanly onto external
//  providers (Google Places / Foursquare / Yelp) in the future.
//

import Foundation

struct Place: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    /// Intentions this place satisfies (a place can match several).
    let intentions: [Intention]
    let coordinate: Coordinate
    /// One-line category label, e.g. "Historic Landmark".
    let categoryLabel: String
    /// Why it matters — the short editorial reason to visit.
    let whyItMatters: String
    /// Longer description for the place detail screen.
    let description: String
    let address: String
    /// 0.0–5.0 rating used for ranking.
    let rating: Double
    /// Rough price tier 0 (free) to 4 ($$$$). Optional.
    let priceTier: Int?
    /// SF Symbol used as the visual stand-in for a photo.
    let symbol: String
    /// Optional Wikipedia article title used to fetch a real photo at runtime.
    /// When nil (or the lookup fails), the UI falls back to a styled gradient.
    var imageTitle: String? = nil
    /// Suggested minutes to spend here.
    let suggestedMinutes: Int
    /// Optional opening hours; nil means "always open / unknown".
    let openingHours: OpeningHours?
    /// Optional insider tip.
    let insiderTip: String?
    /// Optional nearby food recommendation.
    let foodRecommendation: String?
    /// Whether this is iconic / a must-see (boosts ranking).
    let isIconic: Bool

    /// Convenience: whether the place serves a given intention.
    func matches(_ intention: Intention) -> Bool {
        if intention == .surpriseMe { return true }
        return intentions.contains(intention)
    }
}

/// Simplified opening-hours model. Real providers expose per-day ranges; for
/// the MVP we model a single open/close window plus optional closed days.
struct OpeningHours: Codable, Hashable {
    /// Hour of day [0–24) the place opens.
    let opensAtHour: Int
    /// Hour of day [0–24) the place closes.
    let closesAtHour: Int
    /// Weekday numbers (1 = Sunday ... 7 = Saturday) the place is closed.
    let closedWeekdays: [Int]

    /// Whether the place is open at the given date.
    func isOpen(at date: Date, calendar: Calendar = .current) -> Bool {
        let hour = calendar.component(.hour, from: date)
        let weekday = calendar.component(.weekday, from: date)
        if closedWeekdays.contains(weekday) { return false }
        if closesAtHour > opensAtHour {
            return hour >= opensAtHour && hour < closesAtHour
        } else {
            // Overnight window (e.g. nightlife 18:00–02:00).
            return hour >= opensAtHour || hour < closesAtHour
        }
    }

    var displayString: String {
        String(format: "%02d:00 – %02d:00", opensAtHour, closesAtHour)
    }

    static let alwaysOpen = OpeningHours(opensAtHour: 0, closesAtHour: 24, closedWeekdays: [])
}
