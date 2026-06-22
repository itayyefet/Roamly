//
//  RoamlyTypography.swift
//  Roamly
//
//  Typography tokens built on the SF system font with Dynamic Type support.
//

import SwiftUI

enum RoamlyFont {
    /// Big hero/display title (e.g. splash, large headers).
    static let display = Font.system(size: 34, weight: .bold, design: .rounded)
    /// Screen title.
    static let title = Font.system(size: 26, weight: .bold, design: .rounded)
    /// Section / card title.
    static let headline = Font.system(size: 19, weight: .semibold, design: .rounded)
    /// Emphasis subtitle.
    static let subheadline = Font.system(size: 16, weight: .semibold)
    /// Body copy.
    static let body = Font.system(size: 16, weight: .regular)
    /// Secondary body / supporting copy.
    static let callout = Font.system(size: 14, weight: .regular)
    /// Small labels, chips, metadata.
    static let caption = Font.system(size: 12.5, weight: .medium)
    /// Tiny overline labels (uppercased eyebrows).
    static let overline = Font.system(size: 11, weight: .semibold)
}

extension View {
    /// Applies the Roamly overline style: small, tracked, uppercased.
    func roamlyOverline() -> some View {
        self.font(RoamlyFont.overline)
            .textCase(.uppercase)
            .kerning(0.8)
            .foregroundStyle(RoamlyColor.textSecondary)
    }
}
