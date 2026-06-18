//
//  RoamlyCard.swift
//  Roamly
//
//  Reusable elevated card container used across the app.
//

import SwiftUI

struct RoamlyCard<Content: View>: View {
    var padding: CGFloat = RoamlySpacing.md
    var background: Color = RoamlyColor.surface
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: RoamlyRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: RoamlyRadius.lg, style: .continuous)
                    .strokeBorder(RoamlyColor.separator.opacity(0.6), lineWidth: 0.5)
            )
            .roamlyShadow(.subtle)
    }
}

/// A card style modifier for views that want the card surface without nesting.
extension View {
    func roamlyCardStyle(padding: CGFloat = RoamlySpacing.md) -> some View {
        self
            .padding(padding)
            .background(RoamlyColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: RoamlyRadius.lg, style: .continuous))
            .roamlyShadow(.subtle)
    }
}
