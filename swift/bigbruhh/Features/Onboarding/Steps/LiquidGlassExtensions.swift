//
//  LiquidGlassExtensions.swift
//  bigbruhh
//
//  Shared liquid glass extensions for all step components
//

import SwiftUI

// MARK: - Liquid Glass Extensions

extension View {
    /// Glass effect for VoiceStep and ChoiceStep buttons
    @ViewBuilder
    func applyVoiceGlassEffect(prominent: Bool, accentColor: Color) -> some View {
        if #available(iOS 26.0, *) {
            if prominent {
                self.glassEffect(.regular.tint(accentColor).interactive())
            } else {
                self.glassEffect(.regular.interactive())
            }
        } else {
            // Fallback for older iOS versions
            if prominent {
                self.background(accentColor.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                self.background(Color.gray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
    
    
    /// Glass effect for choice step buttons with proper text color adaptation
    @ViewBuilder
    func applyChoiceGlassEffect(isSelected: Bool, accentColor: Color) -> some View {
        if #available(iOS 26.0, *) {
            if isSelected {
                self.glassEffect(.regular.tint(accentColor).interactive())
            } else {
                self.glassEffect(.regular.interactive())
            }
        } else {
            // Fallback for older iOS versions
            if isSelected {
                self.background(accentColor.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                self.background(Color.gray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
    
    /// Glass effect for general step buttons (TimePickerStep, ExplanationStep, etc.)
    @ViewBuilder
    func applyStepGlassEffect(prominent: Bool, accentColor: Color) -> some View {
        if #available(iOS 26.0, *) {
            if prominent {
                self.glassEffect(.regular.tint(accentColor).interactive())
            } else {
                self.glassEffect(.regular.interactive())
            }
        } else {
            // Fallback for older iOS versions
            if prominent {
                self.background(accentColor.opacity(0.3))
                    .clipShape(Capsule())
            } else {
                self.background(Color.gray.opacity(0.3))
                    .clipShape(Capsule())
            }
        }
    }
}
