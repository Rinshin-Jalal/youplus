//
//  ChromaticAberration.swift
//  bigbruhh
//
//  RGB chromatic aberration effect for high-stakes moments
//

import SwiftUI

struct ChromaticAberrationModifier: ViewModifier {
    let isActive: Bool
    let intensity: CGFloat

    func body(content: Content) -> some View {
        if isActive {
            ZStack {
                // Red channel - offset left
                content
                    .colorMultiply(.red)
                    .offset(x: -intensity, y: 0)
                    .opacity(0.7)

                // Green channel - center (original position)
                content
                    .colorMultiply(.green)
                    .opacity(0.7)

                // Blue channel - offset right
                content
                    .colorMultiply(.blue)
                    .offset(x: intensity, y: 0)
                    .opacity(0.7)
            }
            .blendMode(.screen)
        } else {
            content
        }
    }
}

extension View {
    /// Apply RGB chromatic aberration effect
    /// - Parameters:
    ///   - isActive: Whether the effect is currently active
    ///   - intensity: Pixel offset for RGB channels (default: 2.0)
    func chromaticAberration(isActive: Bool, intensity: CGFloat = 2.0) -> some View {
        self.modifier(ChromaticAberrationModifier(isActive: isActive, intensity: intensity))
    }
}

// MARK: - Glitch Effect (combines chromatic aberration with shake)

struct GlitchEffect: ViewModifier {
    let isGlitching: Bool
    @State private var offset: CGSize = .zero

    func body(content: Content) -> some View {
        content
            .chromaticAberration(isActive: isGlitching, intensity: 3.0)
            .offset(offset)
            .onChange(of: isGlitching) { _, newValue in
                if newValue {
                    // Shake animation
                    withAnimation(.linear(duration: 0.05).repeatCount(6, autoreverses: true)) {
                        offset = CGSize(width: 2, height: -1)
                    }

                    // Reset after animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.linear(duration: 0.05)) {
                            offset = .zero
                        }
                    }
                }
            }
    }
}

extension View {
    /// Apply glitch effect (chromatic aberration + screen shake)
    func glitchEffect(isActive: Bool) -> some View {
        self.modifier(GlitchEffect(isGlitching: isActive))
    }
}

#Preview {
    struct PreviewContainer: View {
        @State private var isGlitching = false

        var body: some View {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                VStack(spacing: 40) {
                    Text("LIE DETECTED")
                        .font(.system(size: 48, weight: .black))
                        .foregroundColor(.brutalRed)
                        .glitchEffect(isActive: isGlitching)

                    Text("CHROMATIC ABERRATION TEST")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .chromaticAberration(isActive: isGlitching, intensity: 4.0)

                    Button("TRIGGER GLITCH") {
                        isGlitching = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isGlitching = false
                        }
                    }
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.brutalRed)
                    .cornerRadius(4)
                }
            }
        }
    }

    return PreviewContainer()
}
