//
//  ViewExtensions.swift
//  bigbruhh
//
//  Shared view extensions for conditional modifiers
//

import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Apply voice glass effect for recording buttons
    /// Uses iOS 26+ liquid glass button styles with fallback for older versions
    @ViewBuilder
    func applyVoiceGlassEffect(prominent: Bool, accentColor: Color) -> some View {
        if #available(iOS 26.0, *) {
            // Use button styles for buttons (proper Liquid Glass API)
            if prominent {
                self.buttonStyle(.glassProminent)
            } else {
                self.buttonStyle(.glass)
            }
        } else {
            // Fallback for iOS 17 and below
            self
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(
                            LinearGradient(
                                colors: [
                                    accentColor.opacity(prominent ? 0.3 : 0.2),
                                    accentColor.opacity(prominent ? 0.2 : 0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(accentColor.opacity(0.4), lineWidth: 1)
                        )
                )
        }
    }
}
