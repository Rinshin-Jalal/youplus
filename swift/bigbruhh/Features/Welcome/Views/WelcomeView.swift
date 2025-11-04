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
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Simple centered message
                Text("Ready?")
                    .font(.system(size: 48, weight: .black))
                    .foregroundColor(.white)

                Spacer()

                // Single button
                VStack(spacing: 16) {
                    Button(action: handleStartTalking) {
                        Text("START")
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                            .background(Color.brutalRed)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 24)

                    // Sign in link
                    Button(action: handleSignIn) {
                        Text("Sign in")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.bottom, 40)
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
