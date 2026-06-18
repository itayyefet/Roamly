//
//  HomeView.swift
//  Roamly
//
//  The home screen: detected city, greeting, intention & time selection,
//  primary CTAs, recent trips and nearby highlights.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var env: AppEnvironment
    @EnvironmentObject private var location: LocationService
    @EnvironmentObject private var savedTrips: SavedTripsStore

    @StateObject private var vm = HomeViewModel()
    @State private var path: [AppRoute] = []
    @State private var showCityPicker = false

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: RoamlySpacing.lg) {
                    header
                    intentionSection
                    timeSection
                    ctaSection
                    if !recentTrips.isEmpty { recentSection }
                    if !vm.nearbyHighlights.isEmpty { nearbySection }
                    Color.clear.frame(height: RoamlySpacing.lg)
                }
                .padding(.horizontal, RoamlySpacing.screenInset)
                .padding(.top, RoamlySpacing.sm)
            }
            .background(RoamlyColor.background.ignoresSafeArea())
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.inline)
            .roamlyNavigationDestinations(path: $path)
            .sheet(isPresented: $showCityPicker) {
                CityPickerView { city in
                    Task { await vm.selectCity(city) }
                }
            }
        }
        .task {
            vm.configure(env: env, location: location)
            await vm.start()
        }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: RoamlySpacing.sm) {
            Button {
                showCityPicker = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: vm.usingApproximateLocation ? "mappin.and.ellipse" : "location.fill")
                        .font(.system(size: 13, weight: .semibold))
                    Text(vm.greetingCityText)
                        .font(RoamlyFont.subheadline)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundStyle(RoamlyColor.primaryBlue)
                .padding(.vertical, 7)
                .padding(.horizontal, 12)
                .background(RoamlyColor.primaryBlue.opacity(0.10))
                .clipShape(Capsule())
            }
            .buttonStyle(PressableButtonStyle())

            Text("What kind of city experience\ndo you want right now?")
                .font(RoamlyFont.title)
                .foregroundStyle(RoamlyColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            if vm.locationDenied {
                approximateNotice(
                    "Location is off — showing \(vm.city?.name ?? "a demo city"). Tap the city above to change it."
                )
            } else if vm.usingApproximateLocation {
                approximateNotice("Using an approximate location. Tap the city to choose your own.")
            }
        }
    }

    private func approximateNotice(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(RoamlyColor.warning)
            Text(text)
                .font(RoamlyFont.caption)
                .foregroundStyle(RoamlyColor.textSecondary)
        }
        .padding(RoamlySpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoamlyColor.warning.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: RoamlyRadius.sm, style: .continuous))
    }

    private var intentionSection: some View {
        VStack(alignment: .leading, spacing: RoamlySpacing.sm) {
            sectionHeader("I'm in the mood for", systemImage: "heart.text.square.fill")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: RoamlySpacing.xs) {
                    ForEach(Intention.selectableCategories) { intention in
                        RoamlySelectableChip(
                            title: intention.title,
                            systemImage: intention.symbol,
                            isSelected: vm.selectedIntention == intention
                        ) {
                            vm.selectIntention(intention)
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
            .scrollClipDisabled()
        }
    }

    private var timeSection: some View {
        VStack(alignment: .leading, spacing: RoamlySpacing.sm) {
            sectionHeader("How much time do you have?", systemImage: "clock.fill")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: RoamlySpacing.xs) {
                    ForEach(TripDuration.allCases) { duration in
                        RoamlySelectableChip(
                            title: duration.shortLabel,
                            systemImage: duration.symbol,
                            isSelected: vm.selectedDuration == duration
                        ) {
                            vm.selectedDuration = duration
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
            .scrollClipDisabled()
        }
    }

    private var ctaSection: some View {
        VStack(spacing: RoamlySpacing.sm) {
            RoamlyButton(
                title: vm.selectedIntention == nil ? "Pick a vibe to begin" : "Create My Route",
                systemImage: "wand.and.stars",
                kind: .accent
            ) {
                if let intention = vm.selectedIntention,
                   let query = vm.makeQuery(forIntention: intention) {
                    path.append(.routeOptions(query))
                }
            }
            .opacity(vm.canCreateRoute ? 1 : 0.55)
            .disabled(!vm.canCreateRoute)

            RoamlyButton(title: "Surprise Me", systemImage: "dice.fill", kind: .secondary) {
                if let query = vm.makeQuery(forIntention: .surpriseMe) {
                    path.append(.routeOptions(query))
                }
            }
            .disabled(vm.start == nil)
        }
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: RoamlySpacing.sm) {
            sectionHeader("Recent trips", systemImage: "clock.arrow.circlepath")
            ForEach(recentTrips) { trip in
                Button {
                    path.append(.routeDetail(trip.route))
                } label: {
                    RecentTripRow(trip: trip)
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
    }

    private var nearbySection: some View {
        VStack(alignment: .leading, spacing: RoamlySpacing.sm) {
            sectionHeader("Nearby highlights", systemImage: "sparkles")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: RoamlySpacing.sm) {
                    ForEach(vm.nearbyHighlights) { place in
                        Button {
                            path.append(.placeDetail(place))
                        } label: {
                            NearbyPlaceCard(place: place)
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }
                .padding(.horizontal, 2)
                .padding(.bottom, 4)
            }
            .scrollClipDisabled()
        }
    }

    private func sectionHeader(_ title: String, systemImage: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(RoamlyColor.accentOrange)
            Text(title)
                .font(RoamlyFont.headline)
                .foregroundStyle(RoamlyColor.textPrimary)
        }
    }

    private var recentTrips: [SavedTrip] {
        Array(savedTrips.trips.prefix(3))
    }
}

/// A compact recent-trip row.
private struct RecentTripRow: View {
    let trip: SavedTrip

    var body: some View {
        HStack(spacing: RoamlySpacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: RoamlyRadius.sm, style: .continuous)
                    .fill(trip.route.intention.tint.opacity(0.15))
                    .frame(width: 46, height: 46)
                Image(systemName: trip.route.intention.symbol)
                    .foregroundStyle(trip.route.intention.tint)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(trip.route.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(RoamlyColor.textPrimary)
                    .lineLimit(1)
                Text("\(trip.route.cityName) · \(trip.route.durationText) · \(trip.route.stopCount) stops")
                    .font(RoamlyFont.caption)
                    .foregroundStyle(RoamlyColor.textSecondary)
                    .lineLimit(1)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(RoamlyColor.textSecondary)
        }
        .roamlyCardStyle(padding: RoamlySpacing.sm)
    }
}

#Preview {
    let env = AppEnvironment.makeDefault()
    return HomeView()
        .environmentObject(env)
        .environmentObject(env.locationService)
        .environmentObject(env.savedTripsStore)
}
