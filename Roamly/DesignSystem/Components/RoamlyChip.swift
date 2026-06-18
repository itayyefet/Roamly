//
//  RoamlyChip.swift
//  Roamly
//
//  Selectable chips for intentions and time selection, plus a small read-only
//  tag chip used on route/place cards.
//

import SwiftUI

/// An interactive, selectable chip (used for intentions & durations).
struct RoamlySelectableChip: View {
    let title: String
    var systemImage: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            #if canImport(UIKit)
            UISelectionFeedbackGenerator().selectionChanged()
            #endif
            action()
        }) {
            HStack(spacing: 6) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 13, weight: .semibold))
                }
                Text(title)
                    .font(RoamlyFont.caption)
            }
            .padding(.vertical, 9)
            .padding(.horizontal, 14)
            .foregroundStyle(isSelected ? RoamlyColor.textOnAccent : RoamlyColor.textPrimary)
            .background(
                Group {
                    if isSelected {
                        RoamlyColor.primaryBlue
                    } else {
                        RoamlyColor.surfaceSecondary
                    }
                }
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(
                        isSelected ? Color.clear : RoamlyColor.separator,
                        lineWidth: 0.5
                    )
            )
        }
        .buttonStyle(PressableButtonStyle())
    }
}

/// A small, read-only tag chip (used on cards for metadata/tags).
struct RoamlyTagChip: View {
    let title: String
    var systemImage: String? = nil
    var tint: Color = RoamlyColor.primaryBlue

    var body: some View {
        HStack(spacing: 4) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 10, weight: .semibold))
            }
            Text(title)
                .font(RoamlyFont.overline)
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 9)
        .foregroundStyle(tint)
        .background(tint.opacity(0.12))
        .clipShape(Capsule())
    }
}
