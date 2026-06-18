//
//  StateViews.swift
//  Roamly
//
//  Reusable empty / error / loading states so no screen is ever blank.
//

import SwiftUI

/// A friendly empty-state placeholder.
struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: RoamlySpacing.md) {
            ZStack {
                Circle()
                    .fill(RoamlyColor.primaryBlue.opacity(0.10))
                    .frame(width: 96, height: 96)
                Image(systemName: systemImage)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(RoamlyColor.primaryBlue)
            }
            Text(title)
                .font(RoamlyFont.headline)
                .foregroundStyle(RoamlyColor.textPrimary)
                .multilineTextAlignment(.center)
            Text(message)
                .font(RoamlyFont.callout)
                .foregroundStyle(RoamlyColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, RoamlySpacing.lg)
            if let actionTitle, let action {
                RoamlyButton(title: actionTitle, kind: .primary, fullWidth: false, action: action)
                    .padding(.top, RoamlySpacing.xs)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(RoamlySpacing.lg)
    }
}

/// An error-state placeholder with a retry affordance.
struct ErrorStateView: View {
    let title: String
    let message: String
    var retryTitle: String = "Try Again"
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: RoamlySpacing.md) {
            ZStack {
                Circle()
                    .fill(RoamlyColor.danger.opacity(0.10))
                    .frame(width: 96, height: 96)
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 38, weight: .medium))
                    .foregroundStyle(RoamlyColor.danger)
            }
            Text(title)
                .font(RoamlyFont.headline)
                .foregroundStyle(RoamlyColor.textPrimary)
                .multilineTextAlignment(.center)
            Text(message)
                .font(RoamlyFont.callout)
                .foregroundStyle(RoamlyColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, RoamlySpacing.lg)
            RoamlyButton(title: retryTitle, systemImage: "arrow.clockwise",
                         kind: .primary, fullWidth: false, action: onRetry)
        }
        .frame(maxWidth: .infinity)
        .padding(RoamlySpacing.lg)
    }
}

/// A simple branded loading state.
struct LoadingStateView: View {
    var message: String = "Building your route…"

    var body: some View {
        VStack(spacing: RoamlySpacing.md) {
            ProgressView()
                .controlSize(.large)
                .tint(RoamlyColor.primaryBlue)
            Text(message)
                .font(RoamlyFont.callout)
                .foregroundStyle(RoamlyColor.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
