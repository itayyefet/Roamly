//
//  ItineraryView.swift
//  Roamly
//
//  The step-by-step guided itinerary. Each stop shows why it matters, time to
//  spend, walking time to the next stop, address, insider tips, food picks and
//  any inserted breaks. Supports multi-day (weekend) grouping.
//

import SwiftUI

struct ItineraryView: View {
    @EnvironmentObject private var env: AppEnvironment
    @EnvironmentObject private var savedTrips: SavedTripsStore

    let route: Route
    @Binding var path: [AppRoute]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: RoamlySpacing.md) {
                summaryHeader

                if route.duration.isMultiDay {
                    multiDayBody
                } else {
                    ForEach(route.stops) { stop in
                        stopCard(stop)
                    }
                }
                Color.clear.frame(height: 90)
            }
            .padding(.horizontal, RoamlySpacing.screenInset)
            .padding(.top, RoamlySpacing.sm)
        }
        .background(RoamlyColor.background.ignoresSafeArea())
        .navigationTitle("Itinerary")
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
            bottomBar
        }
    }

    private var summaryHeader: some View {
        RoamlyCard {
            VStack(alignment: .leading, spacing: RoamlySpacing.xs) {
                Text(route.title)
                    .font(RoamlyFont.headline)
                    .foregroundStyle(RoamlyColor.textPrimary)
                HStack(spacing: RoamlySpacing.md) {
                    RoamlyMetric(systemImage: "clock.fill", value: route.durationText)
                    RoamlyMetric(systemImage: "figure.walk", value: route.walkingDistanceText)
                    RoamlyMetric(systemImage: "mappin.circle.fill", value: "\(route.stopCount) stops")
                }
            }
        }
    }

    @ViewBuilder
    private var multiDayBody: some View {
        let days = Dictionary(grouping: route.stops, by: { $0.day })
            .sorted { $0.key < $1.key }
        ForEach(days, id: \.key) { day, stops in
            VStack(alignment: .leading, spacing: RoamlySpacing.sm) {
                HStack(spacing: 8) {
                    Image(systemName: "\(day).circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(RoamlyColor.accentOrange)
                    Text("Day \(day)")
                        .font(RoamlyFont.title)
                        .foregroundStyle(RoamlyColor.textPrimary)
                }
                .padding(.top, RoamlySpacing.xs)
                ForEach(stops) { stop in
                    stopCard(stop)
                }
            }
        }
    }

    private func stopCard(_ stop: RouteStop) -> some View {
        VStack(spacing: RoamlySpacing.xs) {
            ItineraryStopCard(stop: stop,
                              isLast: stop.id == route.stops.last?.id,
                              onOpenPlace: { path.append(.placeDetail(stop.place)) },
                              onNavigate: { env.mapService.openInAppleMaps(place: stop.place) })

            if let brk = stop.breakSuggestion {
                BreakRow(suggestion: brk)
            }
        }
    }

    private var bottomBar: some View {
        HStack(spacing: RoamlySpacing.sm) {
            RoamlyButton(title: "Map View", systemImage: "map.fill", kind: .secondary) {
                path.append(.mapNavigation(route))
            }
            RoamlyButton(title: "Navigate", systemImage: "location.fill", kind: .accent) {
                env.mapService.openItineraryInAppleMaps(stops: route.stops)
            }
        }
        .padding(.horizontal, RoamlySpacing.screenInset)
        .padding(.vertical, RoamlySpacing.sm)
        .background(.ultraThinMaterial)
        .overlay(Divider(), alignment: .top)
    }
}

/// A single detailed stop card in the itinerary.
struct ItineraryStopCard: View {
    let stop: RouteStop
    var isLast: Bool
    var onOpenPlace: () -> Void
    var onNavigate: () -> Void

    var body: some View {
        RoamlyCard {
            VStack(alignment: .leading, spacing: RoamlySpacing.sm) {
                HStack(alignment: .top, spacing: RoamlySpacing.sm) {
                    StopPin(number: stop.order)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(stop.place.name)
                            .font(RoamlyFont.headline)
                            .foregroundStyle(RoamlyColor.textPrimary)
                        Text(stop.place.categoryLabel)
                            .font(RoamlyFont.caption)
                            .foregroundStyle(RoamlyColor.accentOrange)
                    }
                    Spacer()
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill").font(.system(size: 11))
                            .foregroundStyle(RoamlyColor.warning)
                        Text(String(format: "%.1f", stop.place.rating))
                            .font(RoamlyFont.caption)
                            .foregroundStyle(RoamlyColor.textSecondary)
                    }
                }

                Text(stop.place.whyItMatters)
                    .font(RoamlyFont.callout)
                    .foregroundStyle(RoamlyColor.textSecondary)

                HStack(spacing: RoamlySpacing.md) {
                    Label("Spend ~\(stop.suggestedMinutes) min", systemImage: "hourglass")
                    if stop.walkingMinutesToNext > 0 {
                        Label(stop.walkingToNextText, systemImage: "figure.walk")
                    } else {
                        Label("Final stop", systemImage: "flag.checkered")
                    }
                }
                .font(RoamlyFont.overline)
                .foregroundStyle(RoamlyColor.textSecondary)

                Label(stop.place.address, systemImage: "mappin.and.ellipse")
                    .font(RoamlyFont.caption)
                    .foregroundStyle(RoamlyColor.textSecondary)
                    .lineLimit(1)

                if let tip = stop.place.insiderTip {
                    InsiderTipView(text: tip)
                }

                if let food = stop.place.foodRecommendation {
                    HStack(spacing: 6) {
                        Image(systemName: "fork.knife")
                            .foregroundStyle(RoamlyColor.accentOrange)
                        Text(food)
                            .font(RoamlyFont.caption)
                            .foregroundStyle(RoamlyColor.textSecondary)
                    }
                }

                HStack(spacing: RoamlySpacing.sm) {
                    RoamlyButton(title: "Details", systemImage: "info.circle", kind: .secondary, action: onOpenPlace)
                    RoamlyButton(title: "Go", systemImage: "arrow.triangle.turn.up.right.diamond.fill", kind: .primary, action: onNavigate)
                }
                .padding(.top, 2)
            }
        }
    }
}

/// A subtle highlighted insider-tip callout.
struct InsiderTipView: View {
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(RoamlyColor.warning)
                .font(.system(size: 13))
            Text(text)
                .font(RoamlyFont.caption)
                .foregroundStyle(RoamlyColor.textPrimary)
        }
        .padding(RoamlySpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoamlyColor.warning.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: RoamlyRadius.sm, style: .continuous))
    }
}

/// An inserted coffee/meal/restroom break row.
struct BreakRow: View {
    let suggestion: BreakSuggestion
    var body: some View {
        HStack(spacing: RoamlySpacing.sm) {
            Image(systemName: suggestion.kind.symbol)
                .foregroundStyle(RoamlyColor.accentOrange)
            VStack(alignment: .leading, spacing: 1) {
                Text(suggestion.kind.label)
                    .font(RoamlyFont.caption)
                    .foregroundStyle(RoamlyColor.textPrimary)
                Text(suggestion.text)
                    .font(RoamlyFont.caption)
                    .foregroundStyle(RoamlyColor.textSecondary)
            }
            Spacer()
        }
        .padding(RoamlySpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoamlyColor.accentOrange.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: RoamlyRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: RoamlyRadius.md, style: .continuous)
                .strokeBorder(RoamlyColor.accentOrange.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
        )
    }
}
