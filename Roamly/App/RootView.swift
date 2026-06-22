//
//  RootView.swift
//  Roamly
//
//  Drives the top-level flow: Splash -> Onboarding -> Main tabs.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var env: AppEnvironment
    @State private var phase: Phase = .splash

    enum Phase {
        case splash
        case onboarding
        case main
    }

    var body: some View {
        ZStack {
            switch phase {
            case .splash:
                SplashView {
                    advanceFromSplash()
                }
                .transition(.opacity)
            case .onboarding:
                OnboardingFlowView {
                    env.hasCompletedOnboarding = true
                    withAnimation(.easeInOut) { phase = .main }
                }
                .transition(.opacity)
            case .main:
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: phase)
    }

    private func advanceFromSplash() {
        if env.hasCompletedOnboarding {
            phase = .main
        } else {
            phase = .onboarding
        }
    }
}

/// The main tab container shown after onboarding.
struct MainTabView: View {
    @EnvironmentObject private var env: AppEnvironment

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Explore", systemImage: "map.fill") }

            SavedTripsView()
                .tabItem { Label("Saved", systemImage: "bookmark.fill") }

            PassportView()
                .tabItem { Label("Passport", systemImage: "trophy.fill") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AppEnvironment.makeDefault())
        .environmentObject(AppEnvironment.makeDefault().locationService)
}
