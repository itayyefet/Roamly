//
//  RouteNarrating.swift
//  Roamly
//
//  Abstraction for a short, friendly "guide note" that introduces a route. The
//  MVP ships a deterministic local narrator; an LLM-backed narrator can be
//  swapped in behind the same protocol for personalized, on-brand copy.
//

import Foundation

protocol RouteNarrating {
    /// Returns a short (1–2 sentence) introduction to the route.
    func narrate(_ route: Route) async -> String
}

/// A deterministic, offline narrator. Always available, no network, no cost.
struct MockRouteNarrator: RouteNarrating {
    func narrate(_ route: Route) async -> String {
        let first = route.stops.first?.place.name
        let highlight = route.stops.first(where: { $0.place.isIconic })?.place.name ?? first
        let vibe = route.intention == .surpriseMe ? "a little bit of everything" : route.intention.title.lowercased()
        let opener: String
        switch route.kind {
        case .bestOverall: opener = "Here's a well-balanced take on \(route.cityName)"
        case .localFavorite: opener = "This one leans local"
        case .efficient: opener = "Tightly routed to save your feet"
        }
        let highlightClause = highlight.map { " starting near \($0)" } ?? ""
        return "\(opener) — \(route.stopCount) stops of \(vibe) over about \(route.durationText)\(highlightClause). Enjoy the walk!"
    }
}
