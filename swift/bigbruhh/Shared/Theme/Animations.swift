//
//  Animations.swift
//  bigbruhh
//
//  Reusable animation modifiers for "fun" interactions
//

import SwiftUI

// MARK: - Animation Presets
struct AnimationPresets {
    static let fadeIn = Animation.easeIn(duration: 0.6)
    static let slideUp = Animation.spring(response: 0.6, dampingFraction: 0.8)
    static let buttonGlow = Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)
    static let pulse = Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
}

// MARK: - Bouncy Press Modifier
struct BouncyPressModifier: ViewModifier {
    let scale: CGFloat
    
    func body(content: Content) -> some View {
        content
            .buttonStyle(BouncyButtonStyle(scale: scale))
    }
}

struct BouncyButtonStyle: ButtonStyle {
    let scale: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Floating Animation Modifier
struct FloatingModifier: ViewModifier {
    let distance: CGFloat
    let duration: Double
    
    @State private var isFloating = false
    
    func body(content: Content) -> some View {
        content
            .offset(y: isFloating ? -distance : distance)
            .animation(
                .easeInOut(duration: duration)
                .repeatForever(autoreverses: true),
                value: isFloating
            )
            .onAppear {
                isFloating = true
            }
    }
}

// MARK: - Pulse Animation Modifier
struct PulseModifier: ViewModifier {
    let scale: CGFloat
    let duration: Double
    
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? scale : 1.0)
            .animation(
                .easeInOut(duration: duration)
                .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

// MARK: - Shine/Gradient Animation Modifier
struct ShineModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.2), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + (phase * geometry.size.width * 2))
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

// MARK: - View Extensions
extension View {
    func bouncyPress(scale: CGFloat = 0.95) -> some View {
        self.modifier(BouncyPressModifier(scale: scale))
    }
    
    func floating(distance: CGFloat = 5, duration: Double = 2.0) -> some View {
        self.modifier(FloatingModifier(distance: distance, duration: duration))
    }
    
    func pulse(scale: CGFloat = 1.05, duration: Double = 1.0) -> some View {
        self.modifier(PulseModifier(scale: scale, duration: duration))
    }
    
    func shineEffect() -> some View {
        self.modifier(ShineModifier())
    }
}