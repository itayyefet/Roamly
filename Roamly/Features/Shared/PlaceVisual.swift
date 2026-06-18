//
//  PlaceVisual.swift
//  Roamly
//
//  A place's hero image. When the place has a resolvable photo (via Wikipedia),
//  it loads asynchronously; otherwise — or while loading, or if it fails — it
//  shows a brand-tinted gradient with the place's SF Symbol. This keeps the UI
//  rich whether or not a real photo is available.
//

import SwiftUI

struct PlaceVisual: View {
    let place: Place
    var height: CGFloat = 120
    var cornerRadius: CGFloat = RoamlyRadius.md

    @State private var imageURL: URL?

    var body: some View {
        ZStack {
            // Base layer: always present, acts as placeholder + fallback.
            gradient
            Image(systemName: place.symbol)
                .font(.system(size: height * 0.32, weight: .semibold))
                .foregroundStyle(.white.opacity(0.92))
                .shadow(color: .black.opacity(0.15), radius: 6, y: 3)

            // Photo layer: covers the base once loaded.
            if let imageURL {
                AsyncImage(url: imageURL, transaction: Transaction(animation: .easeInOut(duration: 0.25))) { phase in
                    if case .success(let image) = phase {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        Color.clear
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .task(id: place.id) {
            guard let title = PlaceImageCatalog.title(for: place) else { return }
            imageURL = await PlaceImageService.shared.imageURL(forTitle: title)
        }
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
