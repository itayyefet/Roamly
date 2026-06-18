//
//  OnboardingFlowView.swift
//  Roamly
//
//  A short, friendly onboarding that explains the value and the location
//  permission, then requests it. Gracefully handles denial.
//

import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject private var env: AppEnvironment
    @EnvironmentObject private var location: LocationService
    let onComplete: () -> Void

    @State private var page = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            symbol: "sparkle.magnifyingglass",
            title: "No planning required",
            message: "Open Roamly and get an instant, guided sightseeing route built around where you are right now."
        ),
        OnboardingPage(
            symbol: "slider.horizontal.3",
            title: "Your vibe, your time",
            message: "Tell us the kind of experience you want and how long you have. We'll craft the perfect walk."
        ),
        OnboardingPage(
            symbol: "location.fill.viewfinder",
            title: "We use your location",
            message: "Roamly needs your location to detect your city and build routes around you. It's only used while you explore — never sold or shared."
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, item in
                    OnboardingPageView(page: item)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            VStack(spacing: RoamlySpacing.sm) {
                if page < pages.count - 1 {
                    RoamlyButton(title: "Continue", kind: .primary) {
                        withAnimation { page += 1 }
                    }
                    Button("Skip") { onComplete() }
                        .font(RoamlyFont.callout)
                        .foregroundStyle(RoamlyColor.textSecondary)
                } else {
                    RoamlyButton(title: "Enable Location", systemImage: "location.fill", kind: .accent) {
                        location.requestPermission()
                        location.requestLocation()
                        onComplete()
                    }
                    Button("Not now — I'll pick a city") { onComplete() }
                        .font(RoamlyFont.callout)
                        .foregroundStyle(RoamlyColor.textSecondary)
                }
            }
            .padding(.horizontal, RoamlySpacing.screenInset)
            .padding(.bottom, RoamlySpacing.lg)
        }
        .background(RoamlyColor.background.ignoresSafeArea())
    }
}

struct OnboardingPage {
    let symbol: String
    let title: String
    let message: String
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: RoamlySpacing.lg) {
            Spacer()
            ZStack {
                Circle()
                    .fill(RoamlyColor.primaryBlue.opacity(0.10))
                    .frame(width: 180, height: 180)
                Image(systemName: page.symbol)
                    .font(.system(size: 72, weight: .medium))
                    .foregroundStyle(RoamlyColor.primaryBlue)
            }
            VStack(spacing: RoamlySpacing.sm) {
                Text(page.title)
                    .font(RoamlyFont.title)
                    .foregroundStyle(RoamlyColor.textPrimary)
                    .multilineTextAlignment(.center)
                Text(page.message)
                    .font(RoamlyFont.body)
                    .foregroundStyle(RoamlyColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, RoamlySpacing.lg)
            }
            Spacer()
            Spacer()
        }
        .padding(.horizontal, RoamlySpacing.screenInset)
    }
}

#Preview {
    OnboardingFlowView(onComplete: {})
        .environmentObject(AppEnvironment.makeDefault())
        .environmentObject(AppEnvironment.makeDefault().locationService)
}
