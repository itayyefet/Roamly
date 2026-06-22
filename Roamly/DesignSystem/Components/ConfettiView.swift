//
//  ConfettiView.swift
//  Roamly
//
//  A lightweight, dependency-free confetti burst used to celebrate finishing a
//  route. Drop it in a ZStack overlay and toggle `isActive`.
//

import SwiftUI

struct ConfettiView: View {
    var isActive: Bool
    var pieceCount: Int = 90

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<pieceCount, id: \.self) { index in
                    ConfettiPiece(isActive: isActive, index: index, size: geo.size)
                }
            }
            .allowsHitTesting(false)
        }
    }
}

private struct ConfettiPiece: View {
    let isActive: Bool
    let index: Int
    let size: CGSize

    @State private var animate = false

    private let colors: [Color] = [
        RoamlyColor.accentOrange, RoamlyColor.primaryBlue,
        Color(hex: 0x2BA84A), Color(hex: 0x8E5BE8), Color(hex: 0xE0A100)
    ]

    private var rng: (start: CGFloat, drift: CGFloat, delay: Double, spin: Double, scale: CGFloat) {
        // Deterministic pseudo-random based on the index.
        let s = CGFloat((index * 73 % 100)) / 100
        let d = CGFloat(((index * 37) % 100) - 50) / 100
        let delay = Double((index * 13) % 60) / 100
        let spin = Double((index % 2 == 0) ? 1 : -1) * (360 + Double((index * 17) % 360))
        let scale = 0.6 + CGFloat((index * 29) % 50) / 100
        return (s, d, delay, spin, scale)
    }

    var body: some View {
        let params = rng
        RoundedRectangle(cornerRadius: 2)
            .fill(colors[index % colors.count])
            .frame(width: 8 * params.scale, height: 12 * params.scale)
            .rotationEffect(.degrees(animate ? params.spin : 0))
            .position(
                x: params.start * size.width + (animate ? params.drift * 120 : 0),
                y: animate ? size.height + 40 : -40
            )
            .opacity(animate ? 0 : 1)
            .onChange(of: isActive) { _, active in
                guard active else { return }
                animate = false
                withAnimation(.easeIn(duration: 2.2).delay(params.delay)) {
                    animate = true
                }
            }
            .onAppear {
                if isActive {
                    withAnimation(.easeIn(duration: 2.2).delay(params.delay)) {
                        animate = true
                    }
                }
            }
    }
}
