//
//  Typography.swift
//  BigBruh
//
//  Typography system - Modern Operational Analytics
//

import SwiftUI

extension Font {
    // MARK: - Display (Huge hero text)
    static let displayLarge = Font.system(size: 48, weight: .bold, design: .default)
    static let displayMedium = Font.system(size: 36, weight: .bold, design: .default)

    // MARK: - Headlines
    static let headline = Font.system(size: 24, weight: .bold, design: .default)
    static let headlineMedium = Font.system(size: 22, weight: .bold, design: .default)
    static let headlineSmall = Font.system(size: 20, weight: .bold, design: .default)

    // MARK: - Titles
    static let titleLarge = Font.system(size: 18, weight: .semibold, design: .default)
    static let title = Font.system(size: 16, weight: .semibold, design: .default)
    static let titleSmall = Font.system(size: 14, weight: .semibold, design: .default)

    // MARK: - Body Text
    static let bodyLarge = Font.system(size: 18, weight: .regular, design: .default)
    static let bodyRegular = Font.system(size: 16, weight: .regular, design: .default)
    static let bodyMedium = Font.system(size: 14, weight: .regular, design: .default)
    static let bodyBold = Font.system(size: 16, weight: .semibold, design: .default)

    // MARK: - Caption/Small Text
    static let caption = Font.system(size: 13, weight: .regular, design: .default)
    static let captionMedium = Font.system(size: 12, weight: .medium, design: .default)
    static let captionSmall = Font.system(size: 11, weight: .regular, design: .default)

    // MARK: - Data/Monospace
    static let dataLarge = Font.system(size: 24, weight: .bold, design: .monospaced)
    static let dataMedium = Font.system(size: 18, weight: .semibold, design: .monospaced)
    static let dataSmall = Font.system(size: 14, weight: .medium, design: .monospaced)

    // MARK: - Buttons
    static let buttonLarge = Font.system(size: 18, weight: .semibold, design: .default)
    static let buttonMedium = Font.system(size: 16, weight: .semibold, design: .default)
    static let buttonSmall = Font.system(size: 14, weight: .semibold, design: .default)

    // MARK: - Specialized (Call Screen, Grades, etc.)
    static let timerHero = Font.system(size: 64, weight: .black, design: .monospaced)
    static let gradeDisplay = Font.system(size: 56, weight: .black, design: .default)
    static let callTimer = Font.system(size: 48, weight: .bold, design: .monospaced)
}

// MARK: - Text Modifiers
extension Text {
    func brutalStyle() -> some View {
        self
            .textCase(.uppercase)
            .kerning(1.0)
            .fontWeight(.bold)
    }

    func letterSpacing(_ spacing: CGFloat) -> some View {
        self.kerning(spacing)
    }

    /// Tight letter spacing for display text
    func tightTracking() -> some View {
        self.kerning(-0.5)
    }

    /// Normal letter spacing
    func normalTracking() -> some View {
        self.kerning(0)
    }

    /// Wide letter spacing for labels and small text
    func wideTracking() -> some View {
        self.kerning(0.5)
    }

    /// Extra wide letter spacing for emphasis
    func extraWideTracking() -> some View {
        self.kerning(1.0)
    }
}

// MARK: - Line Height Constants
enum LineHeight {
    static let tight: CGFloat = 1.1
    static let normal: CGFloat = 1.4
    static let relaxed: CGFloat = 1.6
    static let loose: CGFloat = 1.8
}