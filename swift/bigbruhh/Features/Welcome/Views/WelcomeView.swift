//
//  WelcomeView.swift
//  bigbruhh
//
//  STEP 1 - Welcome Screen Implementation
//  Migrated from: nrn/components/WelcomeScreen.tsx
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var navigator: AppNavigator

    var body: some View {
        ZStack {
            // Background with subtle gradient
            ZStack {
                Color.brutalBlack
                    .ignoresSafeArea()

                LinearGradient(
                    colors: [
                        Color.brutalBlack,
                        Color.brutalRed.opacity(0.1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }

            VStack(spacing: Spacing.xxxl) {
                Spacer()

                // Hero message
                Text("Ready?")
                    .font(.displayMedium)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 6)

                Spacer()

                // Action buttons
                VStack(spacing: Spacing.md) {
                    // Primary CTA button
                    Button(action: handleStartTalking) {
                        Text("START")
                            .font(.buttonLarge)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: Spacing.buttonHeightLarge)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: Spacing.radiusLarge, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.brutalRedLight, Color.brutalRed],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )

                                    // Subtle highlight
                                    RoundedRectangle(cornerRadius: Spacing.radiusLarge, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.2),
                                                    Color.clear
                                                ],
                                                startPoint: .top,
                                                endPoint: .center
                                            )
                                        )
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: Spacing.radiusLarge, style: .continuous)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.3),
                                                Color.white.opacity(0.1)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ),
                                        lineWidth: Spacing.borderThin
                                    )
                            )
                            .elevation(.high)
                            .wideTracking()
                    }
                    .padding(.horizontal, Spacing.lg)

                    // Secondary sign in link
                    Button(action: handleSignIn) {
                        Text("Sign in")
                            .font(.bodyRegular)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.bottom, Spacing.xxl)
            }
        }
    }

    private func handleStartTalking() {
        navigator.currentScreen = .onboarding
    }

    private func handleSignIn() {
        navigator.showLogin()
    }
}

// MARK: - Preview

#Preview {
    WelcomeView()
}
