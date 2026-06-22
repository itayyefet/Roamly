//
//  NearbyPlaceCard.swift
//  Roamly
//
//  Compact card for the "Nearby highlights" carousel on Home.
//

import SwiftUI

struct NearbyPlaceCard: View {
    let place: Place

    var body: some View {
        VStack(alignment: .leading, spacing: RoamlySpacing.xs) {
            PlaceVisual(place: place, height: 110)
            VStack(alignment: .leading, spacing: 3) {
                Text(place.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(RoamlyColor.textPrimary)
                    .lineLimit(1)
                Text(place.categoryLabel)
                    .font(RoamlyFont.caption)
                    .foregroundStyle(RoamlyColor.textSecondary)
                    .lineLimit(1)
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(RoamlyColor.warning)
                    Text(String(format: "%.1f", place.rating))
                        .font(RoamlyFont.caption)
                        .foregroundStyle(RoamlyColor.textSecondary)
                }
            }
        }
        .frame(width: 180)
        .padding(RoamlySpacing.xs)
        .background(RoamlyColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: RoamlyRadius.lg, style: .continuous))
        .roamlyShadow(.subtle)
    }
}
