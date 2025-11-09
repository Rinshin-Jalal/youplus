//
//  RootView.swift
//  bigbruhh
//
//  Root-level view switcher - NO NESTING!
//

import SwiftUI
import Combine

enum AppScreen {
    case loading
    case welcome
    case onboarding
    // case almostThere  // Removed from flow - onboarding goes directly to paywall
    case paywallIntro // Story-aligned intro before paywall
    case paywall
    case secretPlan // Secret plan paywall $2.99/week starter
    case login // Login screen after payment
    case processing // Onboarding data push after payment
    case home
    case call
}

class AppNavigator: ObservableObject {
    @Published var currentScreen: AppScreen = .loading
    @Published var conversionOnboardingResponse: ConversionOnboardingResponse?

    // Method to show paywall
    func showPaywall() {
        print("🔥🔥🔥 NAVIGATOR: SHOWING PAYWALL 🔥🔥🔥")
        currentScreen = .paywall
    }

    // Method to show processing (after payment & auth)
    func showProcessing() {
        print("⚙️⚙️⚙️ NAVIGATOR: SHOWING PROCESSING ⚙️⚙️⚙️")
        currentScreen = .processing
    }

    // Method to navigate to home
    func navigateToHome() {
        print("🏠🏠🏠 NAVIGATOR: NAVIGATING TO HOME 🏠🏠🏠")
        currentScreen = .home
    }

    // Legacy method (kept for compatibility)
    func showHome() {
        navigateToHome()
    }

    // Method to show secret plan paywall
    func showSecretPlan(userName: String? = nil, source: String = "quick_action") {
        print("🔒🔒🔒 NAVIGATOR: SHOWING SECRET PLAN PAYWALL 🔒🔒🔒")
        currentScreen = .secretPlan
    }


    // Method to show login screen
    func showLogin() {
        print("🔐🔐🔐 NAVIGATOR: SHOWING LOGIN SCREEN 🔐🔐🔐")
        currentScreen = .login
    }

    // Method to show onboarding with parameters
    func showOnboarding(userName: String, planType: String, source: String) {
        print("📝📝📝 NAVIGATOR: SHOWING ONBOARDING WITH PLAN TYPE: \(planType) 📝📝📝")
        currentScreen = .onboarding
    }

    // Method to show call screen
    func showCall() {
        print("📞📞📞 NAVIGATOR: SHOWING CALL SCREEN 📞📞📞")
        currentScreen = .call
    }
}

struct RootView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var navigator = AppNavigator()

    var body: some View {
        ZStack {
            switch navigator.currentScreen {
            case .loading:
                LoadingView()

            case .welcome:
                WelcomeView()
                    .environmentObject(navigator)

            case .onboarding:
                ConversionOnboardingContainer(onComplete: { response in
                    print("✅ Conversion Onboarding completed")
                    print("📊 Goal: \(response.goal)")
                    print("🎯 Commitment: \(response.dailyCommitment)")
                    print("🔊 Voice recordings: \(response.whyItMatters), \(response.costOfQuitting), \(response.commitmentVoice)")
                    print("⏱️ Time spent: \(Int(response.totalTimeSpent / 60)) minutes")
                    print("🎭 Chosen path: \(response.chosenPath)")

                    // Save completed onboarding data in navigator
                    navigator.conversionOnboardingResponse = response

                    // Navigate to paywall intro (story-aligned framing before transaction)
                    navigator.currentScreen = .paywallIntro
                })

            // case .almostThere:
            //     AlmostThereSimpleView()
            //         .environmentObject(navigator)

            case .paywallIntro:
                PaywallIntroView(onContinue: {
                    // Continue to actual paywall
                    navigator.currentScreen = .paywall
                })

            case .paywall:
                PaywallContainerView(source: "conversion_onboarding")
                    .environmentObject(navigator)

            case .secretPlan:
                SecretPlanPaywallView(
                    userName: "BigBruh", // TODO: Get from context
                    source: "quick_action"
                )
                .environmentObject(navigator)


            case .login:
                AuthView()
                    .environmentObject(navigator)

            case .processing:
                ProcessingView(
                    onboardingResponse: navigator.conversionOnboardingResponse,
                    onComplete: {
                        navigator.navigateToHome()
                    }
                )

            case .home:
                AuthGuard {
                    HomeView()
                        .environmentObject(navigator)
                }

            case .call:
                AuthGuard {
                    CallScreen()
                        .environmentObject(navigator)
                }
            }
        }
        .environmentObject(navigator)
        .onAppear {
            print("🚀 RootView onAppear called")
            print("🚀 Current navigator screen: \(navigator.currentScreen)")
            print("🚀 AuthService state - loading: \(authService.loading), authenticated: \(authService.isAuthenticated)")
            determineInitialScreen()

            // Check if there's an active CallKit call
            checkForActiveCall()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // When app comes to foreground, check for active call
            checkForActiveCall()
        }
        // Optimize: Debounce onChange handlers to prevent excessive recomputation
        .onChange(of: authService.loading) { oldValue, newValue in
            // Only process if value actually changed
            guard oldValue != newValue else { return }
            print("🔄 AuthService loading changed to: \(newValue)")
            if !newValue {
                print("🔄 AuthService finished loading, determining screen...")
                determineInitialScreen()
            }
        }
        .onChange(of: authService.isAuthenticated) { oldValue, newValue in
            // Only process if value actually changed
            guard oldValue != newValue else { return }
            print("🔄 AuthService isAuthenticated changed to: \(newValue)")
            // Only auto-navigate if we're not already in a specific screen
            // This prevents overriding manual navigation (like to ProcessingView)
            if navigator.currentScreen == .loading || navigator.currentScreen == .welcome {
                determineInitialScreen()
            }
        }
        .onChange(of: navigator.currentScreen) { oldValue, newValue in
            // Only log if screen actually changed
            guard oldValue != newValue else { return }
            print("🚨🚨🚨 CURRENT SCREEN CHANGED TO: \(newValue) 🚨🚨🚨")
        }
    }

    private func checkForActiveCall() {
        // Get AppDelegate to check for active call
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        // If there's an active CallKit call and we're not already on call screen
        if let activeUUID = appDelegate.callKitManager.activeCallUUID,
           navigator.currentScreen != .call {
            Config.log("📞 Active call detected (UUID: \(activeUUID)), showing CallScreen", category: "Navigation")

            // Make sure we're authenticated first
            if authService.isAuthenticated {
                navigator.showCall()
            }
        }
    }

    private func determineInitialScreen() {
        print("🔍 RootView: determineInitialScreen called")
        print("   authService.loading: \(authService.loading)")
        print("   authService.isAuthenticated: \(authService.isAuthenticated)")
        print("   Current navigator screen before: \(navigator.currentScreen)")

        // DEBUG: Commented out to allow proper auth flow
        // #if DEBUG
        // print("⚠️ DEBUG MODE: Going DIRECTLY to HOME")
        // navigator.currentScreen = .home
        // return
        // #endif

        if authService.loading {
            print("   → Setting screen to .loading")
            navigator.currentScreen = .loading
        } else if !authService.isAuthenticated {
            print("   → Setting screen to .welcome")
            navigator.currentScreen = .welcome
        } else {
            print("   → User authenticated, checking progress...")
            // Authenticated - check onboarding completion
            if authService.user?.onboardingCompleted == true {
                print("   → Onboarding completed - going to home")
                navigator.currentScreen = .home
            } else {
                print("   → Onboarding NOT completed - starting onboarding")
                navigator.currentScreen = .onboarding
            }
        }
        
        print("   → Final navigator screen: \(navigator.currentScreen)")
    }
}

#Preview {
    RootView()
        .environmentObject(AuthService.shared)
}
