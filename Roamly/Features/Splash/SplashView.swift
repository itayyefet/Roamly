//
//  SplashView.swift
//  Roamly
//
//  Branded splash screen. Auto-advances after a short, elegant animation.
//

import SwiftUI

struct SplashView: View {
    let onFinished: () -> Void

    @State private var animate = false

    var body: some View {
        ZStack {
            RoamlyColor.brandGradient
                .ignoresSafeArea()

            VStack(spacing: RoamlySpacing.md) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.14))
                        .frame(width: 132, height: 132)
                        .scaleEffect(animate ? 1.0 : 0.6)
                    Image(systemName: "location.north.circle.fill")
                        .font(.system(size: 66, weight: .semibold))
                        .foregroundStyle(.white)
                        .rotationEffect(.degrees(animate ? 0 : -45))
                }
                .shadow(color: .black.opacity(0.2), radius: 20, y: 10)

                VStack(spacing: 6) {
                    Text("Roamly")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Open. Choose. Explore.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                }
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : 12)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                animate = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                onFinished()
            }
        }
    }
}

#Preview {
    SplashView(onFinished: {})
}
