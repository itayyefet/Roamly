//
//  RoamlyColor.swift
//  Roamly
//
//  Color design tokens. Defined programmatically (with light/dark variants)
//  so the palette is version-controlled and does not depend on an asset
//  catalog. Primary: deep blue. Accent: warm orange. Soft neutral surfaces.
//

import SwiftUI

enum RoamlyColor {

    // MARK: Brand
    /// Deep, premium travel-tech blue. The primary brand color.
    static let primaryBlue = dynamic(
        light: Color(hex: 0x14366B),
        dark: Color(hex: 0x4E86E8)
    )

    /// A slightly lighter blue used for gradients and large surfaces.
    static let primaryBlueSoft = dynamic(
        light: Color(hex: 0x2C5BA8),
        dark: Color(hex: 0x2E5AA8)
    )

    /// Warm orange accent used for CTAs and highlights.
    static let accentOrange = dynamic(
        light: Color(hex: 0xF4791F),
        dark: Color(hex: 0xFF9342)
    )

    static let accentOrangeSoft = dynamic(
        light: Color(hex: 0xFDEBDC),
        dark: Color(hex: 0x3A2A1C)
    )

    // MARK: Surfaces
    /// App background — soft neutral.
    static let background = dynamic(
        light: Color(hex: 0xF6F7F9),
        dark: Color(hex: 0x0E1116)
    )

    /// Elevated card surface.
    static let surface = dynamic(
        light: Color.white,
        dark: Color(hex: 0x1A1F27)
    )

    /// Secondary chip / filled control surface.
    static let surfaceSecondary = dynamic(
        light: Color(hex: 0xEDEFF3),
        dark: Color(hex: 0x242A33)
    )

    // MARK: Text
    static let textPrimary = dynamic(
        light: Color(hex: 0x101521),
        dark: Color(hex: 0xF3F5F8)
    )

    static let textSecondary = dynamic(
        light: Color(hex: 0x5B6472),
        dark: Color(hex: 0xA3ACBA)
    )

    static let textOnAccent = Color.white

    // MARK: Utility
    static let separator = dynamic(
        light: Color(hex: 0xE2E6EC),
        dark: Color(hex: 0x2C333D)
    )

    static let success = Color(hex: 0x2BA84A)
    static let warning = Color(hex: 0xE0A100)
    static let danger = Color(hex: 0xD64545)

    // MARK: Gradients
    static var brandGradient: LinearGradient {
        LinearGradient(
            colors: [primaryBlue, primaryBlueSoft],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [accentOrange, Color(hex: 0xFFB05C)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: Helpers
    private static func dynamic(light: Color, dark: Color) -> Color {
        #if canImport(UIKit)
        return Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
        #else
        return light
        #endif
    }
}

extension Color {
    /// Initialize a color from a hex integer literal, e.g. `0xF4791F`.
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
