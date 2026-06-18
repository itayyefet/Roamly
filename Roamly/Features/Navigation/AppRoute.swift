//
//  AppRoute.swift
//  Roamly
//
//  Type-safe navigation destinations used by the Explore NavigationStack.
//

import Foundation

/// A request to generate routes — carried through navigation.
struct RouteQuery: Hashable {
    let city: City
    let start: Coordinate
    let intention: Intention
    let duration: TripDuration
    let pace: UserPreference.WalkingPace

    func makeRequest(date: Date = Date()) -> RouteRequest {
        var pref = UserPreference.default
        pref.pace = pace
        return RouteRequest(
            city: city,
            start: start,
            intention: intention,
            duration: duration,
            preference: pref,
            date: date
        )
    }
}

enum AppRoute: Hashable {
    case routeOptions(RouteQuery)
    case routeDetail(Route)
    case itinerary(Route)
    case mapNavigation(Route)
    case placeDetail(Place)
}
