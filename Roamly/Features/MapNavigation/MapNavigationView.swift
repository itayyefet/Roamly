//
//  MapNavigationView.swift
//  Roamly
//
//  Full-screen map navigation: numbered pins, a drawn walking path, a focused
//  current-stop card, a "Next Stop" stepper and an Apple Maps hand-off.
//

import SwiftUI
import MapKit

struct MapNavigationView: View {
    @EnvironmentObject private var env: AppEnvironment
    @EnvironmentObject private var location: LocationService

    let route: Route
    @Binding var path: [AppRoute]

    @State private var currentIndex = 0
    @State private var pathCoordinates: [CLLocationCoordinate2D] = []

    private var currentStop: RouteStop { route.stops[currentIndex] }

    var body: some View {
        ZStack(alignment: .bottom) {
            RouteMapView(
                stops: route.stops,
                userCoordinate: location.coordinate,
                pathCoordinates: pathCoordinates,
                highlightedStopID: currentStop.id,
                onSelectStop: { stop in
                    if let idx = route.stops.firstIndex(of: stop) {
                        withAnimation { currentIndex = idx }
                    }
                }
            )
            .ignoresSafeArea(edges: .top)

            navigationCard
                .padding(.horizontal, RoamlySpacing.md)
                .padding(.bottom, RoamlySpacing.sm)
        }
        .navigationTitle("Navigate")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Try to draw a real walking path; falls back to straight lines.
            let coords = route.stops.map { $0.place.coordinate }
            pathCoordinates = await env.mapService.walkingPolyline(through: coords)
        }
    }

    private var navigationCard: some View {
        VStack(spacing: RoamlySpacing.sm) {
            // Progress dots
            HStack(spacing: 6) {
                ForEach(route.stops.indices, id: \.self) { i in
                    Capsule()
                        .fill(i == currentIndex ? RoamlyColor.accentOrange :
                                (i < currentIndex ? RoamlyColor.primaryBlue : RoamlyColor.separator))
                        .frame(width: i == currentIndex ? 22 : 8, height: 6)
                        .animation(.spring(response: 0.3), value: currentIndex)
                }
            }

            HStack(alignment: .top, spacing: RoamlySpacing.sm) {
                StopPin(number: currentStop.order, isHighlighted: true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(currentStop.place.name)
                        .font(RoamlyFont.headline)
                        .foregroundStyle(RoamlyColor.textPrimary)
                        .lineLimit(1)
                    Text(currentStop.place.whyItMatters)
                        .font(RoamlyFont.caption)
                        .foregroundStyle(RoamlyColor.textSecondary)
                        .lineLimit(2)
                    if currentStop.walkingMinutesToNext > 0 {
                        Label("Next: \(currentStop.walkingToNextText)", systemImage: "figure.walk")
                            .font(RoamlyFont.overline)
                            .foregroundStyle(RoamlyColor.accentOrange)
                            .padding(.top, 2)
                    }
                }
                Spacer()
                Button {
                    path.append(.placeDetail(currentStop.place))
                } label: {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(RoamlyColor.primaryBlue)
                }
            }

            HStack(spacing: RoamlySpacing.sm) {
                RoamlyButton(title: "Previous", systemImage: "chevron.left", kind: .secondary) {
                    withAnimation { currentIndex = max(0, currentIndex - 1) }
                }
                .disabled(currentIndex == 0)
                .opacity(currentIndex == 0 ? 0.5 : 1)

                if currentIndex < route.stops.count - 1 {
                    RoamlyButton(title: "Next Stop", systemImage: "chevron.right", kind: .accent) {
                        withAnimation { currentIndex = min(route.stops.count - 1, currentIndex + 1) }
                    }
                } else {
                    RoamlyButton(title: "Open in Maps", systemImage: "map.fill", kind: .accent) {
                        env.mapService.openInAppleMaps(place: currentStop.place)
                    }
                }
            }
        }
        .padding(RoamlySpacing.md)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: RoamlyRadius.lg, style: .continuous))
        .roamlyShadow(.card)
    }
}
