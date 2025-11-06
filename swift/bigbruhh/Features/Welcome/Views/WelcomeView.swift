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
            // FLAT black background - brutalist
            Color.brutalBlack
                .ignoresSafeArea()

            VStack(spacing: Spacing.xxxl) {
                Spacer()

                // Hero message
                Text("Ready?")
                    .font(.displayMedium)
                    .foregroundColor(.white)

                Spacer()

                // Action buttons
                VStack(spacing: Spacing.md) {
                    // FLAT red button - brutalist
                    Button(action: handleStartTalking) {
                        Text("START")
                            .font(.buttonLarge)
                            .fontWeight(.black)
                            .foregroundColor(.white)
                            .wideTracking()
                            .frame(maxWidth: .infinity)
                            .frame(height: Spacing.buttonHeightLarge)
                            .background(
                                RoundedRectangle(cornerRadius: Spacing.radiusSmall, style: .continuous)
                                    .fill(Color.brutalRed)
                            )
                    }
                    .buttonStyleGlassProminentIfAvailable()
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
