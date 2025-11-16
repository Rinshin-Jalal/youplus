//
//  OnboardingDataManager.swift
//  BigBruh
//
//  Manages completed onboarding data that can be accessed across the app
//  (Paywall, Signup, etc.) without resuming in-progress onboarding state
//

import Foundation
import Combine

class OnboardingDataManager: ObservableObject {
    static let shared = OnboardingDataManager()

    // MARK: - Keys

    private enum Keys {
        static let completedOnboardingData = "completed_onboarding_data"
        static let inProgressState = "onboarding_v3_state"
        static let twoFuturesData = "two_futures_onboarding_data"
        static let conversionData = "conversion_onboarding_data"
    }

    // MARK: - Published Properties

    @Published var completedData: OnboardingState?
    @Published var twoFuturesData: TwoFuturesOnboardingResponse?
    @Published var conversionData: ConversionOnboardingResponse?

    // MARK: - Initialization

    private init() {
        loadCompletedData()
        loadTwoFuturesData()
        loadConversionData()
    }

    // MARK: - Public Methods

    /// Save completed onboarding data (called when user finishes all 45 steps)
    func saveCompletedData(_ state: OnboardingState) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(state) {
            UserDefaults.standard.set(encoded, forKey: Keys.completedOnboardingData)
            #if DEBUG
            print("💾 Completed onboarding data saved")
            #endif
            loadCompletedData() // Update published property
        }
    }

    /// Save Two Futures onboarding data (new 30-step flow)
    func saveTwoFuturesData(_ response: TwoFuturesOnboardingResponse) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(response) {
            UserDefaults.standard.set(encoded, forKey: Keys.twoFuturesData)
            #if DEBUG
            print("💾 Two Futures onboarding data saved")
            #endif
            loadTwoFuturesData() // Update published property
        }
    }

    /// Load Two Futures onboarding data from storage
    func loadTwoFuturesData() {
        if let savedData = UserDefaults.standard.data(forKey: Keys.twoFuturesData),
           let decoded = try? JSONDecoder().decode(TwoFuturesOnboardingResponse.self, from: savedData) {
            twoFuturesData = decoded
            #if DEBUG
            print("📂 Two Futures onboarding data loaded")
            #endif
        }
    }

    /// Save Conversion onboarding data (42-step flow)
    func saveConversionData(_ response: ConversionOnboardingResponse) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(response) {
            UserDefaults.standard.set(encoded, forKey: Keys.conversionData)
            #if DEBUG
            print("💾 Conversion onboarding data saved")
            print("   Goal: \(response.goal)")
            print("   Time spent: \(Int(response.totalTimeSpent / 60)) minutes")
            print("   Voice recordings: 3 (whyItMatters, costOfQuitting, commitment)")
            #endif
            loadConversionData() // Update published property
        }
    }

    /// Load Conversion onboarding data from storage
    func loadConversionData() {
        if let savedData = UserDefaults.standard.data(forKey: Keys.conversionData),
           let decoded = try? JSONDecoder().decode(ConversionOnboardingResponse.self, from: savedData) {
            conversionData = decoded
            #if DEBUG
            print("📂 Conversion onboarding data loaded")
            #endif
        }
    }

    /// Load completed onboarding data from storage
    func loadCompletedData() {
        if let savedData = UserDefaults.standard.data(forKey: Keys.completedOnboardingData),
           let decoded = try? JSONDecoder().decode(OnboardingState.self, from: savedData) {
            completedData = decoded
            #if DEBUG
            print("📂 Completed onboarding data loaded")
            #endif
        }
    }

    /// Clear in-progress onboarding state (call on app init to force fresh start)
    func clearInProgressState() async {
        UserDefaults.standard.removeObject(forKey: Keys.inProgressState)
        // Also clear ConversionOnboardingState to ensure fresh start
        UserDefaults.standard.removeObject(forKey: "ConversionOnboardingState")
        #if DEBUG
        print("🧹 In-progress onboarding state cleared - user will start fresh")
        #endif
    }

    /// Clear all onboarding data (for logout/reset)
    func clearAllData() {
        UserDefaults.standard.removeObject(forKey: Keys.completedOnboardingData)
        UserDefaults.standard.removeObject(forKey: Keys.inProgressState)
        completedData = nil
        #if DEBUG
        print("🗑️ All onboarding data cleared")
        #endif
    }

    // MARK: - Computed Properties for Quick Access

    var userName: String? {
        return completedData?.userName
    }

    var brotherName: String {
        return completedData?.brotherName ?? ""
    }

    var allResponses: [Int: UserResponse] {
        return completedData?.responses ?? [:]
    }

    func getResponse(for stepId: Int) -> UserResponse? {
        return completedData?.responses[stepId]
    }

    // Get all voice responses (with base64 audio data)
    var voiceResponses: [UserResponse] {
        return allResponses.values.filter { $0.type == .voice }
    }

    // Get all text responses
    var textResponses: [UserResponse] {
        return allResponses.values.filter { $0.type == .text }
    }

    // Check if onboarding was completed
    var hasCompletedOnboarding: Bool {
        return completedData?.isCompleted ?? false
    }
}
