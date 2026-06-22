//
//  RouteCardView.swift
//  Roamly
//
//  The route option card (Best Overall / Local Favorite / Efficient).
//

import SwiftUI

struct RouteCardView: View {
    let route: Route
    var onStart: () -> Void

    var body: some View {
        RoamlyCard {
            VStack(alignment: .leading, spacing: RoamlySpacing.sm) {
                HStack(spacing: RoamlySpacing.xs) {
                    Image(systemName: route.kind.symbol)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(RoamlyColor.accentOrange)
                    Text(route.kind.title)
                        .roamlyOverline()
                    Spacer()
                }

                Text(route.title)
                    .font(RoamlyFont.headline)
                    .foregroundStyle(RoamlyColor.textPrimary)

                Text(route.summary)
                    .font(RoamlyFont.callout)
                    .foregroundStyle(RoamlyColor.textSecondary)
                    .lineLimit(2)

                HStack(spacing: RoamlySpacing.md) {
                    RoamlyMetric(systemImage: "clock.fill", value: route.durationText)
                    RoamlyMetric(systemImage: "figure.walk", value: route.walkingDistanceText)
                    RoamlyMetric(systemImage: "mappin.circle.fill", value: "\(route.stopCount) stops")
                }
                .padding(.top, 2)

                if let startText = route.startDistanceText {
                    Label(startText, systemImage: "location.fill")
                        .font(RoamlyFont.caption)
                        .foregroundStyle(RoamlyColor.primaryBlue)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(RoamlyColor.primaryBlue.opacity(0.10))
                        .clipShape(Capsule())
                }

                if !route.tags.isEmpty {
                    FlowLayout(spacing: 6) {
                        ForEach(route.tags, id: \.self) { tag in
                            RoamlyTagChip(title: tag)
                        }
                    }
                }

                RoamlyButton(title: "Start Route", systemImage: "play.fill", kind: .primary, action: onStart)
                    .padding(.top, RoamlySpacing.xxs)
            }
        }
    }
}
