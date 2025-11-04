//
//  PaywallView.swift
//  bigbruhh
//
//  Main paywall container - wraps RevenueCat paywall with navigation logic
//

import SwiftUI

struct PaywallContainerView: View {
    @EnvironmentObject var navigator: AppNavigator
    @EnvironmentObject var onboardingData: OnboardingDataManager
    @EnvironmentObject var revenueCat: RevenueCatService
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) private var dismiss

    let source: String

    init(source: String = "unknown") {
        self.source = source
    }

    var body: some View {
        RevenueCatPaywallView(
            source: source,
            onPurchaseComplete: {
                handlePurchaseComplete()
            },
            onDismiss: {
                handleDismiss()
            }
        )
        .environmentObject(revenueCat)
        .onAppear {
            print("🚨🚨🚨 PAYWALL VIEW APPEARED! 🚨🚨🚨")
            debugPrintOnboardingData()
        }
    }

    // MARK: - Handlers

    private func handlePurchaseComplete() {
        print("✅ Purchase completed - determining next screen")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Check if user is already authenticated
            if authService.isAuthenticated {
                print("✅ User already authenticated - checking for onboarding data")
                // User already signed in - check if they have onboarding data to process
                if onboardingData.hasCompletedOnboarding {
                    print("✅ Onboarding data found - going to ProcessingView")
                    navigator.showProcessing()
                } else {
                    print("⚠️ No onboarding data - user already processed or never onboarded")
                    // Let RootView handle it based on DB flags
                    navigator.navigateToHome()
                }
            } else {
                print("❌ User not authenticated - going to login screen")
                // User not authenticated - need to sign in first
                // Flow: Login → (AuthView checks for onboarding data) → ProcessingView or Home
                navigator.showLogin()
            }
        }
    }

    private func handleDismiss() {
        print("👋 User declined paywall")
        // Go back to welcome screen
        navigator.currentScreen = .welcome
        dismiss()
    }

    // MARK: - Debug Helper

    private func debugPrintOnboardingData() {
        print("\n💳 === PAYWALL: Onboarding Data Access ===")
        print("👤 User Name: \(onboardingData.userName ?? "N/A")")
        print("📊 Total Responses: \(onboardingData.allResponses.count)")
        print("🎤 Voice Responses: \(onboardingData.voiceResponses.count)")
        print("📝 Text Responses: \(onboardingData.textResponses.count)")

        // Print all voice recordings (base64 data URLs)
        for voiceResponse in onboardingData.voiceResponses {
            print("  🎙️  Step \(voiceResponse.stepId): \(voiceResponse.duration ?? 0)s")
        }
        print("💳 ================================\n")
    }
}

// MARK: - Preview

#Preview {
    PaywallContainerView()
        .environmentObject(OnboardingDataManager.shared)
}
