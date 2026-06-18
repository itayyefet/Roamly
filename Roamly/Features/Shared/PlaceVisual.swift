//
//  PlaceVisual.swift
//  Roamly
//
//  A reusable "photo-like" gradient thumbnail standing in for a place image.
//  Uses the place's SF Symbol over a deterministic brand-tinted gradient so the
//  UI looks rich without bundling photography. Swap for AsyncImage later.
//
//  TODO: Replace with real imagery from the data provider (AsyncImage URL).
//

import SwiftUI

struct PlaceVisual: View {
    let place: Place
    var height: CGFloat = 120
    var cornerRadius: CGFloat = RoamlyRadius.md

    var body: some View {
        ZStack {
            gradient
            Image(systemName: place.symbol)
                .font(.system(size: height * 0.32, weight: .semibold))
                .foregroundStyle(.white.opacity(0.92))
                .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    private var gradient: LinearGradient {
        // Deterministic hue based on the place id for visual variety.
        // Sum of scalar values is stable across launches (unlike hashValue).
        let seed = place.id.unicodeScalars.reduce(0) { $0 &+ Int($1.value) }
        let hue = Double(seed % 360) / 360.0
        let base = Color(hue: hue, saturation: 0.55, brightness: 0.62)
        let second = Color(hue: hue, saturation: 0.7, brightness: 0.42)
        return LinearGradient(colors: [base, second],
                              startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
