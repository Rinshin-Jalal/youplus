//
//  AuthService.swift
//  BigBruh
//
//  Authentication service matching nrn/contexts/AuthContext.tsx

import Foundation
import SwiftUI
import Combine
import Supabase
import Auth
import PostgREST
import AuthenticationServices
import CryptoKit

typealias SupabaseSession = Auth.Session

@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var session: SupabaseSession? = nil
    @Published var user: User? = nil
    @Published var loading = false  // Start optimistically - loading screen almost never shows
    @Published var isAuthenticated = false
    @Published var guestToken: String? = nil

    private let supabase = SupabaseManager.shared.client
    private var currentNonce: String?

    private init() {
        // Skip initialization in preview mode
        if Config.isPreview {
            Config.log("⚠️ AuthService: Skipping initialization in preview mode", category: "Auth")
            return
        }
        
        Task {
            await initialize()
        }
    }

    // MARK: - Initialization
    func initialize() async {
        // Skip in preview mode
        if Config.isPreview {
            return
        }
        
        Config.log("Initializing AuthService", category: "Auth")

        // Get current session
        do {
            session = try await supabase.auth.session
            if let session = session {
                Config.log("Session found", category: "Auth")
                await fetchUserProfile(userId: session.user.id.uuidString)
            } else {
                // No session - user is not authenticated
                Config.log("No session found", category: "Auth")
                isAuthenticated = false
                user = nil
            }
        } catch {
            Config.log("No existing session: \(error)", category: "Auth")
            // On error, assume no session
            isAuthenticated = false
            user = nil
        }

        loading = false
        Config.log("AuthService initialization complete - loading: \(loading), authenticated: \(isAuthenticated)", category: "Auth")
    }
    
    // MARK: - Auth Status Check
    func checkAuthStatus() async {
        Config.log("Checking auth status", category: "Auth")
        
        do {
            session = try await supabase.auth.session
            if let session = session {
                Config.log("✅ User is authenticated", category: "Auth")
                await fetchUserProfile(userId: session.user.id.uuidString)
            } else {
                Config.log("❌ No active session", category: "Auth")
                await MainActor.run {
                    isAuthenticated = false
                    user = nil
                }
            }
        } catch {
            Config.log("❌ Auth check failed: \(error)", category: "Auth")
            await MainActor.run {
                isAuthenticated = false
                user = nil
            }
        }

        // Listen for auth state changes
        for await state in supabase.auth.authStateChanges {
            Config.log("Auth state changed: \(state.event)", category: "Auth")

            session = state.session
            if let session = state.session {
                await fetchUserProfile(userId: session.user.id.uuidString)
            } else {
                user = nil
                isAuthenticated = false
            }
        }
    }

    // MARK: - Guest Authentication
    func authenticateGuest() async throws {
        Config.log("Authenticating as guest...", category: "Auth")
        
        // If we already have a guest token, don't request another one
        if let token = guestToken {
            Config.log("Using existing guest token", category: "Auth")
            return
        }
        
        do {
            let response: APIResponse<GuestTokenResponse> = try await APIService.shared.post("/auth/guest", body: [:])
            
            if let token = response.data?.token {
                await MainActor.run {
                    self.guestToken = token
                }
                Config.log("✅ Guest authentication successful", category: "Auth")
            } else {
                throw NSError(domain: "AuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get guest token"])
            }
        } catch {
            Config.log("❌ Guest authentication failed: \(error)", category: "Auth")
            throw error
        }
    }

    // MARK: - Sign In with Apple
    func configureAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = NonceGenerator.randomNonce()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = NonceGenerator.sha256(nonce)
        Config.log("Apple Sign In request configured", category: "Auth")
    }

    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws {
        Config.log("Handling Apple authorization credential", category: "Auth")

        guard let tokenData = credential.identityToken,
              let idToken = String(data: tokenData, encoding: .utf8) else {
            currentNonce = nil
            throw NSError(domain: "AuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid identity token"])
        }

        guard let nonce = currentNonce else {
            throw NSError(domain: "AuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing nonce"])
        }

        let session = try await supabase.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: idToken,
                nonce: nonce
            )
        )

        currentNonce = nil

        Config.log("Apple Sign In successful", category: "Auth")
        self.session = session

        // Create user profile
        let fullName = credential.fullName
        let displayName = [fullName?.givenName, fullName?.familyName]
            .compactMap { $0 }
            .joined(separator: " ")

        await createUserProfile(
            userId: session.user.id.uuidString,
            email: session.user.email ?? "",
            name: displayName.isEmpty ? nil : displayName
        )

        await fetchUserProfile(userId: session.user.id.uuidString)
        
        // Identify user with RevenueCat after successful login
        Task {
            await RevenueCatService.shared.identify(userId: session.user.id.uuidString)
        }
        
        // Identify user with Mixpanel and track sign in
        AnalyticsService.shared.identify(userId: session.user.id.uuidString)
        AnalyticsService.shared.track(event: "sign_in_successful", properties: [
            "user_id": session.user.id.uuidString,
            "email": session.user.email ?? ""
        ])
        
        // Set user properties
        AnalyticsService.shared.setUserProperties([
            "user_id": session.user.id.uuidString,
            "email": session.user.email ?? ""
        ])
    }

    // MARK: - Sign Out
    func signOut() async throws {
        Config.log("Signing out", category: "Auth")
        loading = true

        try await supabase.auth.signOut()

        session = nil
        user = nil
        isAuthenticated = false
        loading = false

        // Clear all onboarding data
        OnboardingDataManager.shared.clearAllData()
        
        // Reset analytics
        AnalyticsService.shared.reset()

        Config.log("Sign out successful", category: "Auth")
    }

    // MARK: - User Profile Management
    private func fetchUserProfile(userId: String) async {
        do {
            let response: User = try await supabase
                .from("users")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
                .value

            user = response
            isAuthenticated = true
            Config.log("User profile fetched successfully", category: "Auth")

        } catch {
            Config.log("Failed to fetch user profile: \(error)", category: "Auth")
            // If profile fetch fails, user might not exist in users table
            // but they still have a valid auth session
            // Set authenticated to true but user to nil
            isAuthenticated = true
            user = nil
            Config.log("Set authenticated=true with nil user due to profile fetch failure", category: "Auth")
        }
    }

    private func createUserProfile(userId: String, email: String, name: String?) async {
        do {
            // Check if profile exists
            let existing: [User] = try await supabase
                .from("users")
                .select()
                .eq("id", value: userId)
                .execute()
                .value

            if !existing.isEmpty {
                Config.log("User profile already exists", category: "Auth")
                return
            }

            // Create new profile
            let profileName = name ?? email.components(separatedBy: "@").first ?? "User"

            let _: User = try await supabase
                .from("users")
                .insert([
                    "id": userId,
                    "email": email,
                    "name": profileName
                ])
                .select()
                .single()
                .execute()
                .value

            Config.log("User profile created", category: "Auth")

        } catch {
            Config.log("Failed to create user profile: \(error)", category: "Auth")
        }
    }

    func updateProfile(name: String) async throws {
        guard let userId = user?.id else {
            throw NSError(domain: "AuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
        }

        let _: User = try await supabase
            .from("users")
            .update(["name": name, "updated_at": ISO8601DateFormatter().string(from: Date())])
            .eq("id", value: userId)
            .select()
            .single()
            .execute()
            .value

        await fetchUserProfile(userId: userId)
        Config.log("Profile updated", category: "Auth")
    }
}

// MARK: - Apple Sign In Delegate
class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private var continuation: CheckedContinuation<ASAuthorizationAppleIDCredential, Error>?

    var credential: ASAuthorizationAppleIDCredential {
        get async throws {
            try await withCheckedThrowingContinuation { continuation in
                self.continuation = continuation
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            continuation?.resume(returning: appleIDCredential)
        } else {
            continuation?.resume(throwing: NSError(domain: "AppleSignIn", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid credential"]))
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }
}
