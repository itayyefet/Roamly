//
//  PassportView.swift
//  Roamly
//
//  The explorer "passport": stats for places visited, cities explored and trips
//  finished, plus a grid of unlockable badges. Makes progress feel rewarding.
//

import SwiftUI

struct PassportView: View {
    @EnvironmentObject private var explorer: ExplorerProgressStore

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: RoamlySpacing.lg) {
                    heroCard
                    statsRow
                    badgesSection
                    Color.clear.frame(height: RoamlySpacing.lg)
                }
                .padding(.horizontal, RoamlySpacing.screenInset)
                .padding(.top, RoamlySpacing.sm)
            }
            .background(RoamlyColor.background.ignoresSafeArea())
            .navigationTitle("Passport")
        }
    }

    private var heroCard: some View {
        VStack(spacing: RoamlySpacing.sm) {
            ZStack {
                Circle().fill(Color.white.opacity(0.18)).frame(width: 86, height: 86)
                Image(systemName: "trophy.fill")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(.white)
            }
            Text("\(explorer.earnedBadgeCount) of \(explorer.badges.count) badges")
                .font(RoamlyFont.headline)
                .foregroundStyle(.white)
            Text(explorer.placesVisited == 0
                 ? "Check into your first stop to start your journey."
                 : "You've explored \(explorer.placesVisited) places across \(explorer.citiesExplored) \(explorer.citiesExplored == 1 ? "city" : "cities").")
                .font(RoamlyFont.callout)
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(RoamlySpacing.lg)
        .background(RoamlyColor.brandGradient)
        .clipShape(RoundedRectangle(cornerRadius: RoamlyRadius.lg, style: .continuous))
        .roamlyShadow(.card)
    }

    private var statsRow: some View {
        HStack(spacing: RoamlySpacing.sm) {
            statCard(value: explorer.placesVisited, label: "Places", symbol: "mappin.circle.fill")
            statCard(value: explorer.citiesExplored, label: "Cities", symbol: "building.2.fill")
            statCard(value: explorer.tripsCompleted, label: "Trips", symbol: "flag.checkered")
        }
    }

    private func statCard(value: Int, label: String, symbol: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(RoamlyColor.accentOrange)
            Text("\(value)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(RoamlyColor.textPrimary)
            Text(label)
                .font(RoamlyFont.overline)
                .foregroundStyle(RoamlyColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, RoamlySpacing.md)
        .background(RoamlyColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: RoamlyRadius.lg, style: .continuous))
        .roamlyShadow(.subtle)
    }

    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: RoamlySpacing.sm) {
            Text("Badges")
                .font(RoamlyFont.headline)
                .foregroundStyle(RoamlyColor.textPrimary)
            LazyVGrid(columns: columns, spacing: RoamlySpacing.sm) {
                ForEach(explorer.badges) { badge in
                    BadgeTile(badge: badge)
                }
            }
        }
    }
}

private struct BadgeTile: View {
    let badge: Badge

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(badge.isEarned ? RoamlyColor.accentOrange.opacity(0.16) : RoamlyColor.surfaceSecondary)
                    .frame(width: 60, height: 60)
                Image(systemName: badge.symbol)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(badge.isEarned ? RoamlyColor.accentOrange : RoamlyColor.textSecondary.opacity(0.5))
                if !badge.isEarned {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(RoamlyColor.textSecondary)
                        .offset(x: 20, y: 20)
                }
            }
            Text(badge.title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(badge.isEarned ? RoamlyColor.textPrimary : RoamlyColor.textSecondary)
                .multilineTextAlignment(.center)
            Text(badge.detail)
                .font(.system(size: 10))
                .foregroundStyle(RoamlyColor.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, RoamlySpacing.sm)
        .opacity(badge.isEarned ? 1 : 0.7)
    }
}

#Preview {
    PassportView()
        .environmentObject(ExplorerProgressStore())
}
