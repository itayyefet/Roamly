//
//  RoamlyMetric.swift
//  Roamly
//
//  Small metric pill used to show duration / distance / stop count.
//

import SwiftUI

struct RoamlyMetric: View {
    let systemImage: String
    let value: String
    var label: String? = nil

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(RoamlyColor.accentOrange)
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(RoamlyColor.textPrimary)
                if let label {
                    Text(label)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(RoamlyColor.textSecondary)
                }
            }
        }
    }
}

/// A horizontal row of metrics with consistent spacing.
struct RoamlyMetricRow: View {
    let metrics: [(image: String, value: String)]

    var body: some View {
        HStack(spacing: RoamlySpacing.md) {
            ForEach(Array(metrics.enumerated()), id: \.offset) { _, m in
                RoamlyMetric(systemImage: m.image, value: m.value)
            }
        }
    }
}
