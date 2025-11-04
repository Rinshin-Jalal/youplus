//
//  GlitchTransitionView.swift
//  bigbruhh
//
//  Glitch transition overlay for phase changes
//  Migrated from: nrn/components/onboarding/GlitchTransition.tsx
//

import SwiftUI

enum GlitchMode {
    case glitch
    case dissolve
    case intense
}

struct GlitchTransitionView: View {
    let isVisible: Bool
    let mode: GlitchMode
    let duration: TimeInterval

    @State private var jitter: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var verticalShift: CGFloat = 0
    @State private var colorSeparation: CGFloat = 0
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0

    init(isVisible: Bool, mode: GlitchMode = .glitch, duration: TimeInterval = 0.2) {
        self.isVisible = isVisible
        self.mode = mode
        self.duration = duration
    }

    var body: some View {
        if isVisible {
            ZStack {
                // Background tint
                Rectangle()
                    .fill(tintColor)
                    .ignoresSafeArea()

                // Chromatic aberration (intense mode only)
                if mode == .intense {
                    Rectangle()
                        .fill(Color.red.opacity(0.08))
                        .blendMode(.screen)
                        .offset(x: colorSeparation * 2, y: verticalShift * 0.3)
                        .ignoresSafeArea()

                    Rectangle()
                        .fill(Color.blue.opacity(0.06))
                        .blendMode(.screen)
                        .offset(x: colorSeparation * -2, y: verticalShift * -0.3)
                        .ignoresSafeArea()
                }

                // Horizontal glitch bands
                glitchBands
            }
            .opacity(opacity)
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .allowsHitTesting(false)
            .zIndex(9999)
            .onAppear {
                startAnimation()
            }
            .onChange(of: isVisible) { visible in
                if !visible {
                    stopAnimation()
                }
            }
        }
    }

    // MARK: - Glitch Bands

    @ViewBuilder
    private var glitchBands: some View {
        // Top band
        Rectangle()
            .fill(bandColor)
            .frame(height: 10)
            .offset(x: jitter * multiplier, y: bandTopOffset)
            .offset(y: verticalShift * verticalMultiplier)

        // Bottom band
        Rectangle()
            .fill(bandColor.opacity(0.7))
            .frame(height: 12)
            .offset(x: jitter * -multiplier, y: bandBottomOffset)
            .offset(y: verticalShift * -verticalMultiplier)

        // Additional bands for intense mode
        if mode == .intense {
            Rectangle()
                .fill(bandColor.opacity(0.5))
                .frame(height: 6)
                .offset(x: jitter * multiplier, y: -50)
                .offset(y: verticalShift * verticalMultiplier)

            Rectangle()
                .fill(bandColor.opacity(0.65))
                .frame(height: 8)
                .offset(x: jitter * -multiplier, y: 100)
                .offset(y: verticalShift * -verticalMultiplier)

            Rectangle()
                .fill(bandColor.opacity(0.8))
                .frame(height: 3)
                .offset(x: jitter * multiplier, y: -200)

            Rectangle()
                .fill(bandColor.opacity(0.7))
                .frame(height: 4)
                .offset(x: jitter * -multiplier, y: 180)
        }
    }

    // MARK: - Styling

    private var tintColor: Color {
        switch mode {
        case .glitch:
            return Color.white.opacity(0.06)
        case .dissolve:
            return Color.white.opacity(0.1)
        case .intense:
            return Color.white.opacity(0.15)
        }
    }

    private var bandColor: Color {
        switch mode {
        case .glitch:
            return Color.white.opacity(0.18)
        case .dissolve:
            return Color.white.opacity(0.24)
        case .intense:
            return Color.white.opacity(0.32)
        }
    }

    private var multiplier: CGFloat {
        switch mode {
        case .glitch: return 6
        case .dissolve: return 9
        case .intense: return 12
        }
    }

    private var verticalMultiplier: CGFloat {
        mode == .intense ? 1 : 0
    }

    private var bandTopOffset: CGFloat {
        UIScreen.main.bounds.height * 0.28
    }

    private var bandBottomOffset: CGFloat {
        UIScreen.main.bounds.height * 0.68
    }

    // MARK: - Animations

    private func startAnimation() {
        let isIntense = mode == .intense
        let jitterIntensity: CGFloat = isIntense ? 2.5 : 1
        let animationSpeed: TimeInterval = isIntense ? 0.025 : 0.04

        // Fade in
        withAnimation(.easeIn(duration: animationSpeed)) {
            opacity = 1
        }

        // Jitter sequence
        animateJitter(intensity: jitterIntensity, speed: animationSpeed, repeats: isIntense ? 2 : 1)

        // Intense mode extras
        if isIntense {
            animateVerticalShift()
            animateColorSeparation()
            animateScale()
            animateRotation()
        }

        // Auto fade out
        let fadeOutDelay = max(0.08, duration - 0.08)
        DispatchQueue.main.asyncAfter(deadline: .now() + fadeOutDelay) {
            withAnimation(.linear(duration: 0.08)) {
                opacity = 0
            }
        }
    }

    private func stopAnimation() {
        withAnimation(.linear(duration: 0.06)) {
            opacity = 0
            jitter = 0
            verticalShift = 0
            colorSeparation = 0
            scale = 1
            rotation = 0
        }
    }

    private func animateJitter(intensity: CGFloat, speed: TimeInterval, repeats: Int) {
        var currentJitter = intensity

        for i in 0..<(repeats * 5) {
            let delay = speed * Double(i)
            let values: [CGFloat] = [intensity, -intensity, intensity * 0.7, -intensity * 0.5, 0]
            let targetValue = values[i % 5]

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.linear(duration: speed)) {
                    jitter = targetValue
                }
            }
        }
    }

    private func animateVerticalShift() {
        let values: [CGFloat] = [8, -12, 4, 0]
        for (index, value) in values.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02 * Double(index)) {
                withAnimation(.linear(duration: 0.02)) {
                    verticalShift = value
                }
            }
        }

        // Repeat
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            for (index, value) in values.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02 * Double(index)) {
                    withAnimation(.linear(duration: 0.02)) {
                        verticalShift = value
                    }
                }
            }
        }
    }

    private func animateColorSeparation() {
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03 * Double(i * 2)) {
                withAnimation(.linear(duration: 0.03)) {
                    colorSeparation = 1
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03 * Double(i * 2 + 1)) {
                withAnimation(.linear(duration: 0.03)) {
                    colorSeparation = 0
                }
            }
        }
    }

    private func animateScale() {
        let values: [CGFloat] = [1.02, 0.98, 1]
        for (index, value) in values.enumerated() {
            let timing = index < 2 ? 0.035 : 0.03
            DispatchQueue.main.asyncAfter(deadline: .now() + timing * Double(index)) {
                withAnimation(.linear(duration: timing)) {
                    scale = value
                }
            }
        }
    }

    private func animateRotation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            withAnimation(.linear(duration: 0.025)) {
                rotation = 0.5
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.025) {
            withAnimation(.linear(duration: 0.025)) {
                rotation = -0.8
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.linear(duration: 0.05)) {
                rotation = 0
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack {
            Text("PHASE TRANSITION")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.white)
        }

        GlitchTransitionView(isVisible: true, mode: .intense, duration: 0.22)
    }
}
