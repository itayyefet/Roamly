//
//  RoamlySpacing.swift
//  Roamly
//
//  Spacing, radius, and shadow tokens for a consistent, premium layout rhythm.
//

import SwiftUI

enum RoamlySpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48

    /// Standard horizontal screen inset.
    static let screenInset: CGFloat = 20
}

enum RoamlyRadius {
    static let sm: CGFloat = 10
    static let md: CGFloat = 16
    static let lg: CGFloat = 22
    static let pill: CGFloat = 100
}

struct RoamlyShadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    static let card = RoamlyShadow(
        color: Color.black.opacity(0.08),
        radius: 16,
        x: 0,
        y: 8
    )

    static let subtle = RoamlyShadow(
        color: Color.black.opacity(0.06),
        radius: 8,
        x: 0,
        y: 3
    )
}

extension View {
    func roamlyShadow(_ shadow: RoamlyShadow = .card) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}
