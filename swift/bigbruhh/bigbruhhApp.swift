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
            #if DEBUG
            Config.log("⚠️ App: Skipping initialization in preview mode", category: "App")
            #endif
            return
        }

        #if DEBUG
        Config.log("🔥 BigBruh launching...", category: "App")
        Config.log("Supabase URL: \(Config.supabaseURL)", category: "Config")
        Config.log("RevenueCat Key: \(String(Config.revenueCatAPIKey.prefix(20)))...", category: "Config")
        #endif

        // Clear in-progress onboarding state synchronously to ensure fresh start
        // This must happen before any views are created to prevent race conditions
        UserDefaults.standard.removeObject(forKey: "onboarding_v3_state")
        UserDefaults.standard.removeObject(forKey: "ConversionOnboardingState")
        #if DEBUG
        print("🧹 In-progress onboarding state cleared synchronously - user will start fresh")
        #endif

        // PERFORMANCE: Defer non-critical initialization to background to avoid blocking app launch
        // This follows Apple's guidance to accelerate app launch by deferring work not needed immediately
        Task.detached(priority: .utility) {
            await OnboardingDataManager.shared.clearInProgressState()
        }
        
        // PERFORMANCE: Defer RevenueCat configuration to background thread
        // RevenueCat initialization can be expensive and doesn't need to block app launch
        Task.detached(priority: .utility) {
            await MainActor.run {
                // RevenueCat configuration happens lazily when needed
                // This prevents blocking the main thread during app launch
            }
        }

        // Initialize Analytics (non-blocking)
        Task.detached(priority: .utility) {
            await MainActor.run {
                // AnalyticsService initializes lazily, but ensure it's created
                _ = AnalyticsService.shared
                AnalyticsService.shared.trackSessionStart()
            }
        }

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
