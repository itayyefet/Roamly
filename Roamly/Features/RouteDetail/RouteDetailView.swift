//
//  RouteDetailView.swift
//  Roamly
//
//  Overview of a single route: map preview, key metrics, the stop list and the
//  primary "Start" action. Also lets the user save the trip.
//

import SwiftUI

struct RouteDetailView: View {
    @EnvironmentObject private var env: AppEnvironment
    @EnvironmentObject private var savedTrips: SavedTripsStore

    let route: Route
    @Binding var path: [AppRoute]

    @State private var guideNote: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: RoamlySpacing.md) {
                mapPreview
                headerBlock
                guideCard
                metricsCard
                startDistanceRow
                stopsPreview
                Color.clear.frame(height: 90)
            }
            .padding(.horizontal, RoamlySpacing.screenInset)
            .padding(.top, RoamlySpacing.sm)
        }
        .task {
            if guideNote == nil {
                guideNote = await env.narrator.narrate(route)
            }
        }
        .background(RoamlyColor.background.ignoresSafeArea())
        .navigationTitle(route.kind.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    savedTrips.toggleSave(route)
                } label: {
                    Image(systemName: savedTrips.isSaved(routeID: route.id) ? "bookmark.fill" : "bookmark")
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            startBar
        }
    }

    private var mapPreview: some View {
        RouteMapView(stops: route.stops)
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: RoamlyRadius.lg, style: .continuous))
            .roamlyShadow(.subtle)
            .allowsHitTesting(false)
            .overlay(alignment: .topTrailing) {
                Label("\(route.stopCount) stops", systemImage: "mappin.circle.fill")
                    .font(RoamlyFont.caption)
                    .padding(.vertical, 6).padding(.horizontal, 10)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(RoamlySpacing.xs)
            }
    }

    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: route.kind.symbol)
                    .foregroundStyle(RoamlyColor.accentOrange)
                Text(route.kind.title).roamlyOverline()
            }
            Text(route.title)
                .font(RoamlyFont.title)
                .foregroundStyle(RoamlyColor.textPrimary)
            Text(route.summary)
                .font(RoamlyFont.body)
                .foregroundStyle(RoamlyColor.textSecondary)
            if !route.tags.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(route.tags, id: \.self) { RoamlyTagChip(title: $0) }
                }
                .padding(.top, 2)
            }
        }
    }

    @ViewBuilder
    private var guideCard: some View {
        if let guideNote {
            HStack(alignment: .top, spacing: RoamlySpacing.sm) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(RoamlyColor.accentOrange)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Your guide").roamlyOverline()
                    Text(guideNote)
                        .font(RoamlyFont.callout)
                        .foregroundStyle(RoamlyColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(RoamlySpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoamlyColor.accentOrange.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: RoamlyRadius.lg, style: .continuous))
            .transition(.opacity)
        }
    }

    @ViewBuilder
    private var startDistanceRow: some View {
        if let startText = route.startDistanceText {
            HStack(spacing: RoamlySpacing.sm) {
                Image(systemName: "figure.walk.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(RoamlyColor.primaryBlue)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Getting there").roamlyOverline()
                    Text(startText)
                        .font(RoamlyFont.callout)
                        .foregroundStyle(RoamlyColor.textPrimary)
                }
                Spacer()
            }
            .padding(RoamlySpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoamlyColor.primaryBlue.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: RoamlyRadius.lg, style: .continuous))
        }
    }

    private var metricsCard: some View {
        RoamlyCard {
            HStack {
                metric("clock.fill", route.durationText, "Duration")
                Divider().frame(height: 36)
                metric("figure.walk", route.walkingDistanceText, "Walking")
                Divider().frame(height: 36)
                metric("mappin.circle.fill", "\(route.stopCount)", "Stops")
            }
        }
    }

    private func metric(_ symbol: String, _ value: String, _ label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(RoamlyColor.accentOrange)
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(RoamlyColor.textPrimary)
            Text(label)
                .font(RoamlyFont.overline)
                .foregroundStyle(RoamlyColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var stopsPreview: some View {
        VStack(alignment: .leading, spacing: RoamlySpacing.sm) {
            Text("The route")
                .font(RoamlyFont.headline)
                .foregroundStyle(RoamlyColor.textPrimary)
            ForEach(route.stops) { stop in
                Button {
                    path.append(.placeDetail(stop.place))
                } label: {
                    StopPreviewRow(stop: stop, isLast: stop.id == route.stops.last?.id)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var startBar: some View {
        HStack(spacing: RoamlySpacing.sm) {
            VStack(alignment: .leading, spacing: 0) {
                Text(route.durationText)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(RoamlyColor.textPrimary)
                Text("\(route.stopCount) stops · \(route.walkingDistanceText)")
                    .font(RoamlyFont.caption)
                    .foregroundStyle(RoamlyColor.textSecondary)
            }
            Spacer()
            RoamlyButton(title: "Start", systemImage: "figure.walk", kind: .accent, fullWidth: false) {
                path.append(.itinerary(route))
            }
        }
        .padding(.horizontal, RoamlySpacing.screenInset)
        .padding(.vertical, RoamlySpacing.sm)
        .background(.ultraThinMaterial)
        .overlay(Divider(), alignment: .top)
    }
}

/// A row in the route's stop preview with a connecting timeline.
struct StopPreviewRow: View {
    let stop: RouteStop
    var isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: RoamlySpacing.sm) {
            VStack(spacing: 0) {
                StopPin(number: stop.order)
                if !isLast {
                    Rectangle()
                        .fill(RoamlyColor.separator)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 30)

            VStack(alignment: .leading, spacing: 3) {
                Text(stop.place.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(RoamlyColor.textPrimary)
                Text(stop.place.categoryLabel)
                    .font(RoamlyFont.caption)
                    .foregroundStyle(RoamlyColor.textSecondary)
                HStack(spacing: RoamlySpacing.sm) {
                    Label("\(stop.suggestedMinutes) min", systemImage: "clock")
                    if stop.walkingMinutesToNext > 0 {
                        Label(stop.walkingToNextText, systemImage: "figure.walk")
                    }
                }
                .font(RoamlyFont.overline)
                .foregroundStyle(RoamlyColor.textSecondary)
            }
            .padding(.bottom, isLast ? 0 : RoamlySpacing.md)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(RoamlyColor.textSecondary)
                .padding(.top, 6)
        }
    }
}
