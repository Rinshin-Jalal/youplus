//
//  AuthView.swift
//  BigBruh
//
//  Authentication screen matching nrn/app/(auth)/auth.tsx

import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @StateObject private var authService = AuthService.shared
    @EnvironmentObject var navigator: AppNavigator
    @State private var signingIn = false

    // Animation states
    @State private var fadeInOpacity: Double = 0
    @State private var slideUpOffset: CGFloat = 50
    @State private var buttonGlowScale: CGFloat = 1.0
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        ZStack {

            if authService.loading {
                loadingView
            } else {
                mainContent
            }
        }
        .onAppear {
            startAnimations()
        }
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: Spacing.lg) {
            ProgressView()
                .tint(.brutalRedLight)
                .scaleEffect(1.5)

            Text("Initializing...")
                .font(.bodyBold)
                .foregroundColor(.white)
                .opacity(0.8)
        }
        .scaleEffect(pulseScale)
    }

    // MARK: - Main Content
    private var mainContent: some View {
        VStack(spacing: 0) {
            Spacer()

            // Logo and Description
            VStack() {
                Image("logo-black-no-bg")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 280 )
                    .scaleEffect(pulseScale)

                Text("Accountability begins now.")
                    .font(.system(size: 18, weight: .medium, design: .default))
                    .foregroundColor(.black)
                    .opacity(0.8)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
            }
            .opacity(fadeInOpacity)

            Spacer()

            VStack(spacing: Spacing.xl) {
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        authService.configureAppleRequest(request)
                    },
                    onCompletion: { result in
                        handleAppleSignIn(result)
                    }
                )
                .signInWithAppleButtonStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: 72)
                .cornerRadius(Spacing.radiusMedium)
                .overlay(
                    RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                        .stroke(Color.black, lineWidth: Spacing.borderMedium)
                )
                .shadow(color: Color.brutalBlack.opacity(0.2), radius: 12, x: 0, y: 0)
                .shadow(color: Color.brutalBlack.opacity(0.15), radius: 24, x: 0, y: 12)
                .disabled(signingIn)

                if signingIn {
                    ProgressView()
                        .tint(.black)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.xxxl)
            .padding(.top, Spacing.lg)
            .opacity(fadeInOpacity)
            .offset(y: slideUpOffset)

            Spacer()
        }
    }

    // MARK: - Animations
    private func startAnimations() {
        withAnimation(AnimationPresets.fadeIn) {
            fadeInOpacity = 1
        }

        withAnimation(AnimationPresets.slideUp) {
            slideUpOffset = 0
        }

        withAnimation(AnimationPresets.buttonGlow) {
            buttonGlowScale = 1.02
        }

        withAnimation(AnimationPresets.pulse) {
            pulseScale = 1.005
        }
    }

    // MARK: - Apple Sign In Handler
    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                Config.log("Apple sign in returned unexpected credential", category: "Auth")
                signingIn = false
                return
            }

            HapticManager.medium()
            signingIn = true

            Task {
                do {
                    try await authService.signInWithApple(credential: credential)
                    HapticManager.triggerNotification(.success)
                    Config.log("Apple sign in successful", category: "Auth")

                    // Check if user has completed onboarding data to process
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if OnboardingDataManager.shared.hasCompletedOnboarding {
                            // User has onboarding data - go to processing to push it
                            Config.log("Completed onboarding data found - going to ProcessingView", category: "Auth")
                            navigator.showProcessing()
                        } else {
                            // No onboarding data - RootView will handle navigation
                            // (will check auth + onboarding_completed flag from DB)
                            Config.log("No completed onboarding data - letting RootView determine next screen", category: "Auth")
                        }
                    }
                } catch {
                    HapticManager.triggerNotification(.error)
                    Config.log("Apple sign in failed: \(error)", category: "Auth")
                    signingIn = false
                }
            }

        case .failure(let error):
            Config.log("Apple sign in cancelled or failed: \(error)", category: "Auth")
            signingIn = false
        }
    }
}

// MARK: - Preview
struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
