//
//  Colors.swift
//  BigBruh
//
//  Theme colors - Modern Operational Analytics
//

import SwiftUI

extension Color {
    // MARK: - Brand Colors (Operational Analytics)
    
    // Backgrounds & Panels
    static let lightSageGreen = Color(hex: "#C6D1C0") // Outer background
    static let offBlack = Color(hex: "#1D1D1D") // Primary panel/card background
    static let veryDarkGray = Color(hex: "#2B2B2B") // Secondary panel/card background
    
    // Accents
    static let paleYellow = Color(hex: "#F9E58C")
    static let softRed = Color(hex: "#F25C54")
    static let coolBlue = Color(hex: "#5A7BEF")
    static let brightOrange = Color(hex: "#F7941D")
    static let pastelPink = Color(hex: "#FAD6DC")
    
    // Text Colors
    static let textWhite = Color(hex: "#FFFFFF")
    static let textLightGray = Color(hex: "#CCCCCC")
    static let textBlack = Color(hex: "#000000")
    
    // Status Colors
    static let statusSuccess = Color(hex: "#9FE6A0") // Connected/Success
    static let statusWarning = Color(hex: "#FFD966") // Warning
    static let statusError = Color(hex: "#FF6B6B") // Disconnected/Error

    // MARK: - Semantic Colors
    
    // Backgrounds
    static let appBackground = lightSageGreen
    static let cardBackground = offBlack
    static let cardBackgroundSecondary = veryDarkGray
    
    // Text
    static let primaryText = textWhite
    static let secondaryText = textLightGray
    static let darkText = textBlack
    
    // Actions/Interactive
    static let primaryAction = paleYellow
    static let secondaryAction = coolBlue
    static let destructiveAction = softRed
    
    // Status
    static let success = statusSuccess
    static let warning = statusWarning
    static let error = statusError
    
    // Legacy/Compatibility (Mapping to new theme where possible)
    static let brutalBlack = offBlack
    static let brutalWhite = textWhite
    static let brutalRed = softRed
    
    static let gradeA = statusSuccess
    static let gradeB = statusWarning
    static let gradeC = brightOrange
    static let gradeD = coolBlue
    static let gradeF = softRed
    
    static let info = coolBlue

    // MARK: - UI Element Colors
    static let inputBackground = Color.white.opacity(0.1)
    static let inputBorder = Color.white.opacity(0.2)
    static let surfaceElevated = veryDarkGray
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