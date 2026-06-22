//
//  RouteDestinations.swift
//  Roamly
//
//  Shared destination resolver so any NavigationStack (Explore, Saved) routes
//  AppRoute values to the same screens.
//

import SwiftUI

struct AppRouteDestinationView: View {
    let route: AppRoute
    @Binding var path: [AppRoute]

    var body: some View {
        switch route {
        case .routeOptions(let query):
            RouteOptionsView(query: query, path: $path)
        case .routeDetail(let r):
            RouteDetailView(route: r, path: $path)
        case .itinerary(let r):
            ItineraryView(route: r, path: $path)
        case .mapNavigation(let r):
            MapNavigationView(route: r, path: $path)
        case .placeDetail(let p):
            PlaceDetailView(place: p)
        }
    }
}

extension View {
    /// Wires the standard Roamly navigation destinations to a NavigationStack.
    func roamlyNavigationDestinations(path: Binding<[AppRoute]>) -> some View {
        navigationDestination(for: AppRoute.self) { route in
            AppRouteDestinationView(route: route, path: path)
        }
    }
}
