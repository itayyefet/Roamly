//
//  PlaceVisual.swift
//  Roamly
//
//  A place's hero image, resolved in priority order:
//    1. A bundled asset named "photo-<place.id>" (instant, offline) — drop real
//       images into Assets.xcassets to guarantee photos on any network.
//    2. A real photo fetched from Wikipedia at runtime (when reachable).
//    3. A polished, category-themed gradient card with the place's SF Symbol.
//
//  This means the UI always looks designed, works offline, and upgrades to real
//  photography wherever the network allows it.
//

import SwiftUI

struct PlaceVisual: View {
    let place: Place
    var height: CGFloat = 120
    var cornerRadius: CGFloat = RoamlyRadius.md

    @State private var remoteURL: URL?

    /// A bundled asset for this place, if one ships in the catalog.
    private var bundledImageName: String { "photo-\(place.id)" }

    private var hasBundledImage: Bool {
        #if canImport(UIKit)
        return UIImage(named: bundledImageName) != nil
        #else
        return false
        #endif
    }

    var body: some View {
        ZStack {
            themedPlaceholder

            // Bundled scene: the always-present, offline guarantee.
            if hasBundledImage {
                Image(bundledImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            // A real Wikipedia photo loads on top whenever the network allows,
            // upgrading the bundled scene to an actual photograph.
            if let remoteURL {
                AsyncImage(url: remoteURL, transaction: Transaction(animation: .easeInOut(duration: 0.3))) { phase in
                    if case .success(let image) = phase {
                        image.resizable().scaledToFill()
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
            // Clear any photo from a previously-displayed place so a recycled
            // view never shows the wrong image while the new one resolves.
            remoteURL = nil
            guard let title = PlaceImageCatalog.title(for: place) else { return }
            remoteURL = await PlaceImageService.shared.imageURL(forTitle: title)
        }
    }

    // MARK: Themed placeholder

    private var themedPlaceholder: some View {
        ZStack {
            gradient
            // Soft top sheen for depth.
            LinearGradient(colors: [Color.white.opacity(0.18), .clear],
                           startPoint: .top, endPoint: .center)
            // Large watermark glyph, offset for a dynamic look.
            Image(systemName: place.symbol)
                .font(.system(size: height * 0.62, weight: .semibold))
                .foregroundStyle(.white.opacity(0.10))
                .offset(x: height * 0.28, y: height * 0.18)
            // Foreground glyph.
            Image(systemName: place.symbol)
                .font(.system(size: height * 0.30, weight: .semibold))
                .foregroundStyle(.white.opacity(0.95))
                .shadow(color: .black.opacity(0.18), radius: 6, y: 3)
        }
    }

    private var gradient: LinearGradient {
        // Category-tinted base for a branded, intentional feel, with a stable
        // per-place hue shift so neighbouring cards still feel distinct.
        let seed = place.id.unicodeScalars.reduce(0) { $0 &+ Int($1.value) }
        let shift = Double(seed % 24) - 12          // -12...11 degrees of variety
        let tint = (place.intentions.first ?? .localClassics).tint
        let base = tint.shifted(byHue: shift / 360, brightness: 0.0)
        let deep = tint.shifted(byHue: shift / 360, brightness: -0.18)
        return LinearGradient(colors: [base, deep],
                              startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

private extension Color {
    /// Returns a copy with a small hue rotation and brightness delta.
    func shifted(byHue hueDelta: Double, brightness brightnessDelta: Double) -> Color {
        #if canImport(UIKit)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if UIColor(self).getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            let newHue = (h + CGFloat(hueDelta)).truncatingRemainder(dividingBy: 1.0)
            let newBright = min(max(b + CGFloat(brightnessDelta), 0), 1)
            return Color(hue: Double(newHue < 0 ? newHue + 1 : newHue),
                         saturation: Double(s),
                         brightness: Double(newBright))
        }
        #endif
        return self
    }
}
