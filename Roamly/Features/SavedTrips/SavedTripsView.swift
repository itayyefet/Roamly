//
//  SavedTripsView.swift
//  Roamly
//
//  Saved & favorited trips, with filtering, swipe-to-delete and an empty state.
//

import SwiftUI

struct SavedTripsView: View {
    @EnvironmentObject private var savedTrips: SavedTripsStore
    @State private var path: [AppRoute] = []
    @State private var showFavoritesOnly = false

    private var visibleTrips: [SavedTrip] {
        showFavoritesOnly ? savedTrips.favorites : savedTrips.trips
    }

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if savedTrips.trips.isEmpty {
                    EmptyStateView(
                        systemImage: "bookmark",
                        title: "No saved trips yet",
                        message: "Generate a route you love and tap the bookmark to keep it here for next time."
                    )
                } else {
                    listContent
                }
            }
            .background(RoamlyColor.background.ignoresSafeArea())
            .navigationTitle("Saved Trips")
            .roamlyNavigationDestinations(path: $path)
            .toolbar {
                if !savedTrips.trips.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            withAnimation { showFavoritesOnly.toggle() }
                        } label: {
                            Image(systemName: showFavoritesOnly ? "heart.fill" : "heart")
                                .foregroundStyle(showFavoritesOnly ? RoamlyColor.danger : RoamlyColor.primaryBlue)
                        }
                    }
                }
            }
        }
    }

    private var listContent: some View {
        ScrollView {
            LazyVStack(spacing: RoamlySpacing.sm) {
                if showFavoritesOnly && visibleTrips.isEmpty {
                    EmptyStateView(
                        systemImage: "heart",
                        title: "No favorites yet",
                        message: "Tap the heart on a saved trip to mark it as a favorite."
                    )
                    .padding(.top, RoamlySpacing.xl)
                }
                ForEach(visibleTrips) { trip in
                    Button {
                        path.append(.routeDetail(trip.route))
                    } label: {
                        SavedTripCard(
                            trip: trip,
                            onFavorite: { savedTrips.toggleFavorite(trip) },
                            onDelete: { withAnimation { savedTrips.delete(trip) } }
                        )
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
            .padding(.horizontal, RoamlySpacing.screenInset)
            .padding(.top, RoamlySpacing.sm)
            .padding(.bottom, RoamlySpacing.lg)
        }
    }
}

struct SavedTripCard: View {
    let trip: SavedTrip
    var onFavorite: () -> Void
    var onDelete: () -> Void

    var body: some View {
        RoamlyCard {
            VStack(alignment: .leading, spacing: RoamlySpacing.sm) {
                HStack(spacing: RoamlySpacing.sm) {
                    ZStack {
                        RoundedRectangle(cornerRadius: RoamlyRadius.md, style: .continuous)
                            .fill(trip.route.intention.tint.opacity(0.15))
                            .frame(width: 52, height: 52)
                        Image(systemName: trip.route.intention.symbol)
                            .font(.system(size: 22))
                            .foregroundStyle(trip.route.intention.tint)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(trip.route.title)
                            .font(RoamlyFont.headline)
                            .foregroundStyle(RoamlyColor.textPrimary)
                            .lineLimit(1)
                        Text("\(trip.route.cityName) · \(trip.route.kind.title)")
                            .font(RoamlyFont.caption)
                            .foregroundStyle(RoamlyColor.textSecondary)
                    }
                    Spacer()
                    Button(action: onFavorite) {
                        Image(systemName: trip.isFavorite ? "heart.fill" : "heart")
                            .foregroundStyle(trip.isFavorite ? RoamlyColor.danger : RoamlyColor.textSecondary)
                    }
                    .buttonStyle(.plain)
                }

                HStack(spacing: RoamlySpacing.md) {
                    RoamlyMetric(systemImage: "clock.fill", value: trip.route.durationText)
                    RoamlyMetric(systemImage: "figure.walk", value: trip.route.walkingDistanceText)
                    RoamlyMetric(systemImage: "mappin.circle.fill", value: "\(trip.route.stopCount) stops")
                }
            }
        }
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
            Button(action: onFavorite) {
                Label(trip.isFavorite ? "Unfavorite" : "Favorite",
                      systemImage: trip.isFavorite ? "heart.slash" : "heart")
            }
        }
    }
}
