//
//  Animations.swift
//  BigBruh
//
//  Animation presets matching React Native animations

import SwiftUI
import UIKit

enum AnimationPresets {
    // MARK: - Durations
    static let fast: Double = 0.2
    static let medium: Double = 0.3
    static let slow: Double = 0.4
    static let verySlow: Double = 0.6
    static let ultra: Double = 0.8

    // MARK: - Standard Animations
    static let fadeIn = Animation.easing(duration: 0.4)
    static let slideUp = Animation.easing(duration: 0.8)
    static let bounce = Animation.spring(response: 0.6, dampingFraction: 0.7)

    // MARK: - Button Animations
    static let buttonGlow = Animation.easing(duration: 2.0).repeatForever(autoreverses: true)
    static let pulse = Animation.easing(duration: 3.0).repeatForever(autoreverses: true)

    // MARK: - Typing Effect
    static let typing: Double = 0.02 // 20ms per character

    // MARK: - Call Screen Animations
    static let shake = Animation.easing(duration: 0.05)
    static let moodChange = Animation.easing(duration: 0.5)
    static let shamePopIn = Animation.spring(response: 0.3, dampingFraction: 0.6)
}

// MARK: - Animation Extensions
extension Animation {
    static func easing(duration: Double) -> Animation {
        .timingCurve(0.4, 0.0, 0.2, 1.0, duration: duration)
    }
}

// MARK: - Haptic Feedback Helper
enum HapticManager {
    static func trigger(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    static func triggerNotification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    static func light() {
        trigger(.light)
    }

    static func medium() {
        trigger(.medium)
    }

    static func heavy() {
        trigger(.heavy)
    }
}