//
//  RoamlyButton.swift
//  Roamly
//
//  Primary, accent, and secondary button styles.
//

import SwiftUI

enum RoamlyButtonKind {
    case primary    // deep blue
    case accent     // warm orange — the hero CTA
    case secondary  // neutral filled
    case ghost      // text only
}

struct RoamlyButton: View {
    let title: String
    var systemImage: String? = nil
    var kind: RoamlyButtonKind = .primary
    var fullWidth: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: {
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            action()
        }) {
            HStack(spacing: RoamlySpacing.xs) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.vertical, 15)
            .padding(.horizontal, RoamlySpacing.lg)
            .foregroundStyle(foreground)
            .background(backgroundView)
            .clipShape(RoundedRectangle(cornerRadius: RoamlyRadius.md, style: .continuous))
        }
        .buttonStyle(PressableButtonStyle())
    }

    @ViewBuilder private var backgroundView: some View {
        switch kind {
        case .primary:
            RoamlyColor.brandGradient
        case .accent:
            RoamlyColor.accentGradient
        case .secondary:
            RoamlyColor.surfaceSecondary
        case .ghost:
            Color.clear
        }
    }

    private var foreground: Color {
        switch kind {
        case .primary, .accent: return RoamlyColor.textOnAccent
        case .secondary: return RoamlyColor.textPrimary
        case .ghost: return RoamlyColor.primaryBlue
        }
    }
}

/// A subtle press-scale animation shared by interactive controls.
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
