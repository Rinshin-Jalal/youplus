//
//  Spacing.swift
//  BigBruh
//
//  Spacing constants matching React Native styles

import SwiftUI

enum Spacing {
    // MARK: - Base Spacing Scale (4px base, follows 8px rhythm)
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 40
    static let xxxl: CGFloat = 48
    static let huge: CGFloat = 64

    // MARK: - Screen Edge Padding
    static let screenHorizontal: CGFloat = 20
    static let screenVertical: CGFloat = 16

    // MARK: - Border Radius (Refined)
    static let radiusXS: CGFloat = 4
    static let radiusSmall: CGFloat = 8
    static let radiusMedium: CGFloat = 12
    static let radiusLarge: CGFloat = 16
    static let radiusXL: CGFloat = 20
    static let radiusRound: CGFloat = 9999

    // MARK: - Border Width
    static let borderThin: CGFloat = 1
    static let borderMedium: CGFloat = 1.5
    static let borderThick: CGFloat = 2

    // MARK: - Icon Sizes
    static let iconXS: CGFloat = 16
    static let iconSmall: CGFloat = 20
    static let iconMedium: CGFloat = 24
    static let iconLarge: CGFloat = 32
    static let iconXL: CGFloat = 40

    // MARK: - Button Sizes
    static let buttonHeightSmall: CGFloat = 44
    static let buttonHeightMedium: CGFloat = 52
    static let buttonHeightLarge: CGFloat = 56
    static let buttonHeightHero: CGFloat = 64
}

// MARK: - Shadow System
enum Shadow {
    static let sm = (color: Color.black.opacity(0.1), radius: CGFloat(2), x: CGFloat(0), y: CGFloat(1))
    static let md = (color: Color.black.opacity(0.15), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
    static let lg = (color: Color.black.opacity(0.2), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
    static let xl = (color: Color.black.opacity(0.25), radius: CGFloat(12), x: CGFloat(0), y: CGFloat(6))
    static let xxl = (color: Color.black.opacity(0.3), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(8))

    // Colored shadows for emphasis
    static let redGlow = (color: Color.brutalRed.opacity(0.4), radius: CGFloat(12), x: CGFloat(0), y: CGFloat(0))
    static let greenGlow = (color: Color.success.opacity(0.4), radius: CGFloat(12), x: CGFloat(0), y: CGFloat(0))
}

// MARK: - View Extension for Elevation
extension View {
    func elevation(_ level: ElevationLevel) -> some View {
        modifier(ElevationModifier(level: level))
    }
}

enum ElevationLevel {
    case flat
    case low
    case medium
    case high
    case highest

    var shadow: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        switch self {
        case .flat:
            return Shadow.sm
        case .low:
            return Shadow.md
        case .medium:
            return Shadow.lg
        case .high:
            return Shadow.xl
        case .highest:
            return Shadow.xxl
        }
    }
}

struct ElevationModifier: ViewModifier {
    let level: ElevationLevel

    func body(content: Content) -> some View {
        let shadow = level.shadow
        return content
            .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}