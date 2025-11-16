//
//  Vignette.swift
//  bigbruhh
//
//  Vignette overlay to focus attention on center
//

import SwiftUI

struct Vignette: View {
    var intensity: Double = 0.5 // 0.0 to 1.0

    var body: some View {
        RadialGradient(
            gradient: Gradient(stops: [
                .init(color: Color.white.opacity(0), location: 0.0),
                .init(color: Color.white.opacity(0), location: 0.4),
                .init(color: Color.white.opacity(intensity * 0.03), location: 0.75),
                .init(color: Color.white.opacity(intensity * 0.08), location: 1.0)
            ]),
            center: .center,
            startRadius: 0,
            endRadius: 500
        )
        .blendMode(.overlay)
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

#Preview {
    ZStack {
        Color.brutalBlack
            .ignoresSafeArea()

        VStack(spacing: 32) {
            Text("VIGNETTE TEST")
                .font(.system(size: 32, weight: .black))
                .foregroundColor(.white)

            Text("Notice the darkened edges")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.6))
        }

        Vignette(intensity: 0.5)
    }
}
