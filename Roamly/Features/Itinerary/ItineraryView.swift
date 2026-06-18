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
    @EnvironmentObject private var explorer: ExplorerProgressStore

    let route: Route
    @Binding var path: [AppRoute]

    @State private var showConfetti = false
    @State private var showCompletion = false

    private var visitedCount: Int { explorer.visitedCount(in: route) }
    private var isComplete: Bool { route.stopCount > 0 && visitedCount == route.stopCount }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: RoamlySpacing.md) {
                    summaryHeader
                    progressHeader

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

            ConfettiView(isActive: showConfetti)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            if showCompletion {
                completionOverlay
            }
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

    private var progressHeader: some View {
        RoamlyCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Your progress").roamlyOverline()
                    Spacer()
                    Text("\(visitedCount)/\(route.stopCount) checked in")
                        .font(RoamlyFont.caption)
                        .foregroundStyle(RoamlyColor.textSecondary)
                }
                ProgressView(value: Double(visitedCount), total: Double(max(route.stopCount, 1)))
                    .tint(RoamlyColor.accentOrange)
                if isComplete {
                    Label("Trip complete — nice work!", systemImage: "checkmark.seal.fill")
                        .font(RoamlyFont.caption)
                        .foregroundStyle(RoamlyColor.success)
                } else {
                    Text("Tap “Check in” at each stop as you go.")
                        .font(RoamlyFont.caption)
                        .foregroundStyle(RoamlyColor.textSecondary)
                }
            }
        }
    }

    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()
                .onTapGesture { withAnimation { showCompletion = false } }
            VStack(spacing: RoamlySpacing.md) {
                ZStack {
                    Circle().fill(RoamlyColor.accentOrange.opacity(0.18)).frame(width: 96, height: 96)
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(RoamlyColor.accentOrange)
                }
                Text("Trip Complete! 🎉")
                    .font(RoamlyFont.title)
                    .foregroundStyle(RoamlyColor.textPrimary)
                Text("You explored all \(route.stopCount) stops of \(route.title) in \(route.cityName). It's saved to your Passport.")
                    .font(RoamlyFont.callout)
                    .foregroundStyle(RoamlyColor.textSecondary)
                    .multilineTextAlignment(.center)
                RoamlyButton(title: "Keep Exploring", systemImage: "sparkles", kind: .accent) {
                    withAnimation { showCompletion = false }
                }
            }
            .padding(RoamlySpacing.lg)
            .background(RoamlyColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: RoamlyRadius.lg, style: .continuous))
            .roamlyShadow(.card)
            .padding(.horizontal, RoamlySpacing.xl)
            .transition(.scale.combined(with: .opacity))
        }
    }

    private func checkIn(_ stop: RouteStop) {
        let wasComplete = isComplete
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
        explorer.toggleCheckIn(place: stop.place, cityName: route.cityName)
        if !wasComplete && isComplete {
            celebrateCompletion()
        }
    }

    private func celebrateCompletion() {
        explorer.completeTrip(route)
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
        showConfetti = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation { showConfetti = true }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.15)) {
                showCompletion = true
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
                              isVisited: explorer.isVisited(stop.place.id),
                              onCheckIn: { checkIn(stop) },
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
    var isVisited: Bool = false
    var onCheckIn: () -> Void = {}
    var onOpenPlace: () -> Void
    var onNavigate: () -> Void

    var body: some View {
        RoamlyCard {
            VStack(alignment: .leading, spacing: RoamlySpacing.sm) {
                HStack(alignment: .top, spacing: RoamlySpacing.sm) {
                    StopPin(number: stop.order, isHighlighted: isVisited)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(stop.place.name)
                            .font(RoamlyFont.headline)
                            .foregroundStyle(RoamlyColor.textPrimary)
                            .strikethrough(isVisited, color: RoamlyColor.textSecondary)
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

                checkInButton

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

    private var checkInButton: some View {
        Button(action: onCheckIn) {
            HStack(spacing: 8) {
                Image(systemName: isVisited ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18, weight: .semibold))
                Text(isVisited ? "Checked in" : "Check in here")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                Spacer()
                if isVisited {
                    Image(systemName: "sparkles").font(.system(size: 13))
                }
            }
            .foregroundStyle(isVisited ? RoamlyColor.success : RoamlyColor.primaryBlue)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background((isVisited ? RoamlyColor.success : RoamlyColor.primaryBlue).opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: RoamlyRadius.sm, style: .continuous))
        }
        .buttonStyle(PressableButtonStyle())
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
