//
//  Typography.swift
//  BigBruh
//
//  Typography system matching React Native Inter font styles

import SwiftUI

extension Font {
    // MARK: - Headlines (Inter-Black, Inter-Bold)
    static let headline = Font.system(size: 48, weight: .black, design: .default)
    static let headlineMedium = Font.system(size: 30, weight: .black, design: .default)
    static let headlineSmall = Font.system(size: 24, weight: .bold, design: .default)

    // MARK: - Titles (Inter-Bold)
    static let title = Font.system(size: 20, weight: .bold, design: .default)
    static let titleSmall = Font.system(size: 18, weight: .bold, design: .default)

    // MARK: - Body Text (Inter-Bold, Inter-Regular)
    static let bodyBold = Font.system(size: 16, weight: .bold, design: .default)
    static let bodyRegular = Font.system(size: 16, weight: .regular, design: .default)
    static let bodyLarge = Font.system(size: 26, weight: .black, design: .default)

    // MARK: - Small Text (Inter-Regular)
    static let caption = Font.system(size: 14, weight: .regular, design: .default)
    static let captionSmall = Font.system(size: 12, weight: .regular, design: .default)

    // MARK: - Buttons (Inter-Black)
    static let buttonLarge = Font.system(size: 18, weight: .black, design: .default)
    static let buttonMedium = Font.system(size: 16, weight: .bold, design: .default)

    // MARK: - Call Screen Specific
    static let callTimer = Font.system(size: 24, weight: .bold, design: .default)
    static let callLiveText = Font.system(size: 26, weight: .black, design: .default)
    static let callShameText = Font.system(size: 32, weight: .black, design: .default)
    static let callBigBruhText = Font.system(size: 38, weight: .black, design: .default)
}

// MARK: - Text Modifiers
extension Text {
    func brutalStyle() -> some View {
        self
            .textCase(.uppercase)
            .kerning(2)
    }

    func letterSpacing(_ spacing: CGFloat) -> some View {
        self.kerning(spacing)
    }
}