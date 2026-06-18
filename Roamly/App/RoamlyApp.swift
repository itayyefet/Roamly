//
//  RoamlyApp.swift
//  Roamly
//
//  Open. Choose. Explore.
//  Entry point. Wires up the global app environment and the root navigation flow.
//

import SwiftUI

@main
struct RoamlyApp: App {
    /// Single source of truth for cross-screen state (location, preferences, generation).
    @StateObject private var appEnvironment = AppEnvironment.makeDefault()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appEnvironment)
                .environmentObject(appEnvironment.locationService)
                .environmentObject(appEnvironment.savedTripsStore)
                .tint(RoamlyColor.primaryBlue)
        }
    }
}
