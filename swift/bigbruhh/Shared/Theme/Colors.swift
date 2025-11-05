//
//  Colors.swift
//  BigBruh
//
//  Theme colors matching React Native app

import SwiftUI

extension Color {
    // MARK: - Brand Colors (BRUTALIST - harsh, honest, unapologetic)
    static let brutalBlack = Color(hex: "#000000") // Pure black
    static let brutalWhite = Color(hex: "#FFFFFF") // Pure white
    static let brutalRed = Color(hex: "#FF0033") // BRIGHT red - not refined, not subtle

    // MARK: - Grade Colors (BRUTALIST - flat, bright, clear meaning)
    static let gradeA = Color(hex: "#00D474") // Bright green - success
    static let gradeB = Color(hex: "#FFC107") // Yellow - acceptable
    static let gradeC = Color(hex: "#FF6B00") // Orange - warning
    static let gradeD = Color(hex: "#9C27B0") // Purple - poor
    static let gradeF = Color(hex: "#FF0033") // Red - failure

    // MARK: - Semantic Colors (Reuse grade colors - simple, consistent)
    static let success = gradeA // Bright green
    static let warning = gradeB // Yellow
    static let error = brutalRed // Red
    static let info = Color(hex: "#0091EA") // Bright blue

    // MARK: - UI Element Colors (Minimal - only what's needed)
    static let inputBackground = Color.white.opacity(0.05)
    static let inputBorder = Color.white.opacity(0.2)
    static let surfaceElevated = Color.white.opacity(0.05)
    static let divider = Color.white.opacity(0.1)

    // MARK: - Utility
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // MARK: - Color Utilities

    /// Get appropriate text color (black or white) based on background color luminance
    static func textColor(for backgroundColor: Color) -> Color {
        let uiColor = UIColor(backgroundColor)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let luminance = (0.299 * red + 0.587 * green + 0.114 * blue)
        return luminance > 0.5 ? .black : .white
    }

    /// Get appropriate button text color based on accent color luminance
    /// Use this for text on buttons that have accent color backgrounds
    static func buttonTextColor(for accentColor: Color) -> Color {
        let uiColor = UIColor(accentColor)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let luminance = (0.299 * red + 0.587 * green + 0.114 * blue)
        // For vibrant accent colors, use stricter threshold
        return luminance > 0.55 ? .black : .white
    }

    /// Get luminance value (0-1) of a color
    var luminance: Double {
        let uiColor = UIColor(self)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return 0.299 * red + 0.587 * green + 0.114 * blue
    }
}