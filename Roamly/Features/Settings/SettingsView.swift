//
//  SettingsView.swift
//  Roamly
//
//  Preferences (units, walking pace, demo mode, home city) plus about info.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var env: AppEnvironment
    @EnvironmentObject private var savedTrips: SavedTripsStore

    @State private var prefs: UserPreference = .default
    @State private var cities: [City] = []
    @State private var showResetConfirm = false

    var body: some View {
        NavigationStack {
            Form {
                experienceSection
                locationSection
                dataSection
                aboutSection
            }
            .navigationTitle("Settings")
            .task {
                prefs = env.persistence.loadPreferences()
                cities = await env.dataService.allCities()
            }
            .onChange(of: prefs) { _, newValue in
                env.persistence.savePreferences(newValue)
            }
            .alert("Reset Roamly?", isPresented: $showResetConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) { resetAll() }
            } message: {
                Text("This clears your saved trips and preferences. This can't be undone.")
            }
        }
    }

    private var experienceSection: some View {
        Section("Experience") {
            Picker("Walking pace", selection: $prefs.pace) {
                ForEach(UserPreference.WalkingPace.allCases, id: \.self) { pace in
                    Text(pace.title).tag(pace)
                }
            }
            Picker("Units", selection: $prefs.units) {
                ForEach(UserPreference.Units.allCases, id: \.self) { unit in
                    Text(unit.title).tag(unit)
                }
            }
        }
    }

    private var locationSection: some View {
        Section {
            Toggle(isOn: $prefs.demoModeEnabled) {
                Label("Demo mode", systemImage: "play.tv")
            }
            Picker(selection: Binding(
                get: { prefs.manualCityID ?? "" },
                set: { prefs.manualCityID = $0.isEmpty ? nil : $0 }
            )) {
                Text("Use my location").tag("")
                ForEach(cities) { city in
                    Text("\(city.countryFlag)  \(city.name)").tag(city.id)
                }
            } label: {
                Label("Home city", systemImage: "building.2")
            }
        } header: {
            Text("Location")
        } footer: {
            Text("Demo mode uses a sample city — handy in the Simulator. Setting a home city overrides location detection.")
        }
    }

    private var dataSection: some View {
        Section("Your data") {
            HStack {
                Label("Saved trips", systemImage: "bookmark")
                Spacer()
                Text("\(savedTrips.trips.count)")
                    .foregroundStyle(RoamlyColor.textSecondary)
            }
            Button(role: .destructive) {
                showResetConfirm = true
            } label: {
                Label("Reset app", systemImage: "trash")
            }
        }
    }

    private var aboutSection: some View {
        Section {
            NavigationLink {
                AboutView()
            } label: {
                Label("About Roamly", systemImage: "info.circle")
            }
            HStack {
                Label("Version", systemImage: "number")
                Spacer()
                Text("1.0 (MVP)").foregroundStyle(RoamlyColor.textSecondary)
            }
        } header: {
            Text("About")
        } footer: {
            Text("Roamly — Open. Choose. Explore.\nRoutes are generated locally from a curated sample catalog in this MVP.")
        }
    }

    private func resetAll() {
        for trip in savedTrips.trips { savedTrips.delete(trip) }
        prefs = .default
        env.persistence.savePreferences(.default)
    }
}

/// A small about / branding screen.
struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: RoamlySpacing.md) {
                ZStack {
                    Circle().fill(RoamlyColor.primaryBlue.opacity(0.12)).frame(width: 110, height: 110)
                    Image(systemName: "location.north.circle.fill")
                        .font(.system(size: 54))
                        .foregroundStyle(RoamlyColor.primaryBlue)
                }
                .padding(.top, RoamlySpacing.lg)
                Text("Roamly")
                    .font(RoamlyFont.display)
                    .foregroundStyle(RoamlyColor.textPrimary)
                Text("Open. Choose. Explore.")
                    .font(RoamlyFont.subheadline)
                    .foregroundStyle(RoamlyColor.textSecondary)

                RoamlyCard {
                    Text("Roamly is your smart local guide. No planning required — open the app, choose a vibe and how much time you have, and get an instant, guided sightseeing route built around where you are.")
                        .font(RoamlyFont.body)
                        .foregroundStyle(RoamlyColor.textPrimary)
                }

                RoamlyCard {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Also considered").roamlyOverline()
                        Text("LocalLoop · DriftGuide · CityPulse · Wayfindr · HereNow")
                            .font(RoamlyFont.callout)
                            .foregroundStyle(RoamlyColor.textSecondary)
                    }
                }
            }
            .padding(.horizontal, RoamlySpacing.screenInset)
            .padding(.bottom, RoamlySpacing.lg)
        }
        .background(RoamlyColor.background.ignoresSafeArea())
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}
