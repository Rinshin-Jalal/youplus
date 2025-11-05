//
//  bigbruhhApp.swift
//  bigbruhh
//
//  Created by Rinshin on 01/10/25.
//

import SwiftUI

@main
struct bigbruhhApp: App {
    // Wire AppDelegate for VoIP lifecycle
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // Initialize RevenueCat service
    @StateObject private var revenueCat = RevenueCatService.shared
    @StateObject private var authService = AuthService.shared

    init() {
        // Skip initialization in preview mode to prevent launch failures
        if Config.isPreview {
            Config.log("⚠️ App: Skipping initialization in preview mode", category: "App")
            return
        }

        Config.log("🔥 BigBruh launching...", category: "App")
        Config.log("Supabase URL: \(Config.supabaseURL)", category: "Config")
        Config.log("RevenueCat Key: \(String(Config.revenueCatAPIKey.prefix(20)))...", category: "Config")

        // Supabase handles session persistence automatically
        // Clear in-progress onboarding state on app restart
        // This ensures users start fresh if they haven't completed onboarding
        OnboardingDataManager.shared.clearInProgressState()

        // RevenueCat is configured in RevenueCatService.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(OnboardingDataManager.shared)
                .environmentObject(revenueCat)
                .environmentObject(authService)
                // Provide call managers as environment objects
                .environmentObject(appDelegate.voipManager)
                .environmentObject(appDelegate.callKitManager)
                .environmentObject(appDelegate.callStateStore)
                .environmentObject(appDelegate.sessionController)
                .preferredColorScheme(.dark)
                .tint(.brutalRed) // App-wide accent color for all native controls
        }
    }
}
