//
//  RouteGenerationService.swift
//  Roamly
//
//  The route engine. Given a start coordinate, an intention and a time budget,
//  it builds three differentiated walking routes (Best Overall, Local Favorite,
//  Efficient). It considers distance, walking pace, opening hours, ratings and
//  iconic status, and inserts coffee/meal breaks on longer routes.
//
//  This is intentionally a self-contained, deterministic engine over local
//  data. A future version can defer ranking/sequencing to a backend or an LLM.
//

import Foundation

struct RouteRequest {
    let city: City
    let start: Coordinate
    let intention: Intention
    let duration: TripDuration
    var preference: UserPreference = .default
    var date: Date = Date()
}

enum RouteGenerationError: LocalizedError {
    case noMatchingPlaces
    case notEnoughPlaces

    var errorDescription: String? {
        switch self {
        case .noMatchingPlaces:
            return "We couldn't find spots for that vibe nearby."
        case .notEnoughPlaces:
            return "There aren't enough open places right now to build a full route."
        }
    }
}

final class RouteGenerationService {

    private let dataService: PlacesDataProviding

    init(dataService: PlacesDataProviding) {
        self.dataService = dataService
    }

    /// Builds the three route options for a request.
    func generateRoutes(for request: RouteRequest) async throws -> [Route] {
        let candidates = await candidatePlaces(for: request)
        guard !candidates.isEmpty else { throw RouteGenerationError.noMatchingPlaces }

        let targetCount = targetStopCount(for: request.duration, available: candidates.count)
        guard targetCount >= 1 else { throw RouteGenerationError.notEnoughPlaces }

        let best = buildRoute(kind: .bestOverall, request: request,
                              candidates: rankBestOverall(candidates), targetCount: targetCount)
        let local = buildRoute(kind: .localFavorite, request: request,
                               candidates: rankLocalFavorite(candidates), targetCount: targetCount)
        let efficient = buildRoute(kind: .efficient, request: request,
                                   candidates: rankEfficient(candidates, start: request.start),
                                   targetCount: targetCount)

        return [best, local, efficient].compactMap { $0 }
    }

    // MARK: - Candidate selection

    private func candidatePlaces(for request: RouteRequest) async -> [Place] {
        var places = await dataService.places(in: request.city, matching: request.intention)

        // For "Surprise Me", build a diverse mix across categories.
        if request.intention == .surpriseMe {
            places = diversify(request.city.places)
        }

        // Prefer open places, but never let opening hours empty the list.
        let open = places.filter { place in
            guard let hours = place.openingHours else { return true }
            return hours.isOpen(at: request.date)
        }
        return open.count >= max(2, request.duration.stopRange.lowerBound) ? open : places
    }

    /// Picks a varied selection so Surprise Me isn't all one category.
    private func diversify(_ places: [Place]) -> [Place] {
        var seenCategories = Set<Intention>()
        var result: [Place] = []
        let sorted = places.sorted { ($0.isIconic ? 1 : 0, $0.rating) > ($1.isIconic ? 1 : 0, $1.rating) }
        for place in sorted {
            let primary = place.intentions.first ?? .localClassics
            if !seenCategories.contains(primary) {
                seenCategories.insert(primary)
                result.append(place)
            }
        }
        // Fill remainder with the next best places.
        for place in sorted where !result.contains(where: { $0.id == place.id }) {
            result.append(place)
        }
        return result
    }

    // MARK: - Ranking strategies

    private func rankBestOverall(_ places: [Place]) -> [Place] {
        places.sorted { lhs, rhs in
            if lhs.isIconic != rhs.isIconic { return lhs.isIconic }
            return lhs.rating > rhs.rating
        }
    }

    private func rankLocalFavorite(_ places: [Place]) -> [Place] {
        // Favor hidden gems and highly-rated non-obvious spots.
        places.sorted { lhs, rhs in
            let lScore = localScore(lhs)
            let rScore = localScore(rhs)
            return lScore > rScore
        }
    }

    private func localScore(_ place: Place) -> Double {
        var score = place.rating
        if place.intentions.contains(.hiddenGems) { score += 1.5 }
        if place.intentions.contains(.localClassics) { score += 0.6 }
        if place.isIconic { score -= 0.7 } // de-emphasize the obvious tourist magnets
        return score
    }

    private func rankEfficient(_ places: [Place], start: Coordinate) -> [Place] {
        // Closest to the start first — minimizes total walking.
        places.sorted { $0.coordinate.distance(to: start) < $1.coordinate.distance(to: start) }
    }

    // MARK: - Route assembly

    private func targetStopCount(for duration: TripDuration, available: Int) -> Int {
        let range = duration.stopRange
        let desired = range.upperBound
        return min(desired, available).clamped(min: min(range.lowerBound, available), max: available)
    }

    private func buildRoute(kind: RouteKind, request: RouteRequest,
                            candidates: [Place], targetCount: Int) -> Route? {
        guard !candidates.isEmpty else { return nil }

        // Take the top N by the ranking, then order them into a sensible path
        // via nearest-neighbor from the start to avoid zig-zagging.
        let chosen = Array(candidates.prefix(targetCount))
        let ordered = nearestNeighborOrder(chosen, start: request.start)

        let pace = request.preference.pace.metersPerMinute
        let multiDay = request.duration.isMultiDay
        let perDay = multiDay ? Int(ceil(Double(ordered.count) / 2.0)) : ordered.count

        var stops: [RouteStop] = []
        var totalMeters: Double = 0
        var totalMinutes = 0
        var dayBreaks: [Int] = []

        for (index, place) in ordered.enumerated() {
            let isLast = index == ordered.count - 1
            let day = multiDay ? (index / perDay) + 1 : 1

            if multiDay, index > 0, day != stops.last?.day {
                dayBreaks.append(index)
            }

            // Walking leg to the next stop.
            var legMeters: Double = 0
            var legMinutes = 0
            if !isLast {
                let next = ordered[index + 1]
                legMeters = place.coordinate.distance(to: next.coordinate)
                legMinutes = max(1, Int((legMeters / pace).rounded()))
            }

            // Insert a break roughly mid-route on longer trips.
            let breakSuggestion = breakFor(request: request, index: index, total: ordered.count, place: place)

            let stop = RouteStop(
                id: "\(kind.rawValue)-\(place.id)",
                order: index + 1,
                place: place,
                suggestedMinutes: place.suggestedMinutes,
                walkingMinutesToNext: legMinutes,
                walkingMetersToNext: legMeters,
                breakSuggestion: breakSuggestion,
                day: day
            )
            stops.append(stop)
            totalMeters += legMeters
            totalMinutes += place.suggestedMinutes + legMinutes
            if breakSuggestion != nil { totalMinutes += 20 }
        }

        let route = Route(
            id: "\(request.city.id)-\(request.intention.rawValue)-\(request.duration.rawValue)-\(kind.rawValue)",
            kind: kind,
            title: routeTitle(kind: kind, request: request),
            summary: kind.blurb,
            cityName: request.city.name,
            intention: request.intention,
            duration: request.duration,
            stops: stops,
            totalWalkingMeters: totalMeters,
            estimatedMinutes: totalMinutes,
            tags: routeTags(request: request, stops: stops),
            dayBreaks: multiDay ? dayBreaks : nil
        )
        return route
    }

    /// Orders places by repeatedly walking to the nearest unvisited place.
    private func nearestNeighborOrder(_ places: [Place], start: Coordinate) -> [Place] {
        var remaining = places
        var ordered: [Place] = []
        var current = start
        while !remaining.isEmpty {
            guard let nearestIndex = remaining.indices.min(by: {
                remaining[$0].coordinate.distance(to: current) <
                remaining[$1].coordinate.distance(to: current)
            }) else { break }
            let next = remaining.remove(at: nearestIndex)
            ordered.append(next)
            current = next.coordinate
        }
        return ordered
    }

    private func breakFor(request: RouteRequest, index: Int, total: Int, place: Place) -> BreakSuggestion? {
        guard request.duration.includesMealBreak else { return nil }
        let mid = total / 2
        if index == mid {
            if let food = place.foodRecommendation {
                return BreakSuggestion(kind: .food, text: food)
            }
            return BreakSuggestion(kind: .food, text: "Grab a bite near \(place.name) before continuing.")
        }
        // A coffee/restroom break a bit later on longer routes.
        if total >= 6, index == min(total - 2, mid + 2) {
            return BreakSuggestion(kind: .coffee, text: "Good moment for a coffee and a quick rest stop.")
        }
        return nil
    }

    private func routeTitle(kind: RouteKind, request: RouteRequest) -> String {
        let vibe = request.intention == .surpriseMe ? "\(request.city.name)" : request.intention.title
        switch kind {
        case .bestOverall: return "\(vibe) Highlights"
        case .localFavorite: return "\(vibe) Like a Local"
        case .efficient: return "\(vibe), Smartly Routed"
        }
    }

    private func routeTags(request: RouteRequest, stops: [RouteStop]) -> [String] {
        var tags: [String] = [request.duration.shortLabel]
        if request.intention != .surpriseMe { tags.append(request.intention.title) }
        if stops.contains(where: { $0.place.isIconic }) { tags.append("Iconic") }
        if stops.contains(where: { $0.place.intentions.contains(.hiddenGems) }) { tags.append("Hidden Gems") }
        if request.duration.includesMealBreak { tags.append("Food Stop") }
        return Array(tags.prefix(4))
    }
}

private extension Int {
    func clamped(min lower: Int, max upper: Int) -> Int {
        Swift.min(Swift.max(self, lower), upper)
    }
}
