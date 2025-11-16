//
//  Scanlines.swift
//  bigbruhh
//
//  Subtle scanline effect - surveillance/monitor aesthetic
//

import SwiftUI

struct Scanlines: View {
    var body: some View {
        GeometryReader { _ in
            Canvas { context, _ in
                // Use actual screen dimensions to draw scanlines
                let screenHeight = UIScreen.main.bounds.height
                let screenWidth = UIScreen.main.bounds.width

                // Create path for all scanlines from absolute top to absolute bottom
                var path = Path()
                stride(from: 0, to: screenHeight + 100, by: 2).forEach { y in
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: screenWidth, y: y))
                }

                // Draw with white at 0.1 opacity
                context.stroke(
                    path,
                    with: .color(.white.opacity(0.1)),
                    lineWidth: 1
                )
            }
            .frame(
                width: UIScreen.main.bounds.width,
                height: UIScreen.main.bounds.height + 100
            )
            .position(
                x: UIScreen.main.bounds.width / 2,
                y: UIScreen.main.bounds.height / 2
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .allowsHitTesting(false)
    }
}

#Preview {
    ZStack {
        Color.black
            .ignoresSafeArea()

        Scanlines()

        VStack(spacing: 32) {
            Text("SCANLINE TEST")
                .font(.system(size: 32, weight: .black))
                .foregroundColor(.white)

            Text("Subtle monitor effect")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}
