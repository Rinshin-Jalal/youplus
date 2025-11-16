//
//  PaywallIntroView.swift
//  bigbruhh
//
//  Simplified intro before RevenueCat paywall
//  Minimal, punchy, aligned with onboarding flow
//

import SwiftUI

struct PaywallIntroView: View {
    @Environment(\.dismiss) private var dismiss
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            // Scanline overlay - full screen
            Scanlines()

            VStack(spacing: 32) {
                Spacer()

                // Main message
                VStack(spacing: 24) {
                    Text("you made it through")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .chromaticAberration(isActive: true, intensity: 0.7) // RGB effect
                        .multilineTextAlignment(.center)

                    Text("most people quit at step 5")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                        .chromaticAberration(isActive: true, intensity: 0.5) // Subtle RGB effect
                        .multilineTextAlignment(.center)

                    // Spacer
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 1)
                        .frame(maxWidth: 120)
                        .padding(.vertical, 8)

                    Text("this was free\nwhat comes next costs something")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                        .chromaticAberration(isActive: true, intensity: 0.7) // RGB effect
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    Text("so does quitting")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color(hex: "#FFB800"))
                        .chromaticAberration(isActive: true, intensity: 1.0) // Strong RGB effect for emphasis
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                .padding(.horizontal, 40)

                Spacer()

                // CTA Buttons
                VStack(spacing: 16) {
                    Button(action: onContinue) {
                        Text("i'm in")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(12)

                    Button(action: { dismiss() }) {
                        Text("not ready")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white.opacity(0.5))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview {
    PaywallIntroView(onContinue: {})
}
