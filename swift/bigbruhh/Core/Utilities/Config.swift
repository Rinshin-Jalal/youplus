//
//  Config.swift
//  BigBruh
//
//  App configuration reading from Info.plist (populated by Config.xcconfig)

import Foundation

enum Config {
    // MARK: - Preview Detection
    static var isPreview: Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PLAYGROUNDS"] == "1"
    }
    
    // MARK: - Supabase Configuration
    static let supabaseURL: String = {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "PUBLIC_SUPABASE_URL") as? String else {
            if isPreview {
                return "https://preview.supabase.co"
            }
            fatalError("❌ Missing PUBLIC_SUPABASE_URL in Info.plist")
        }
        return url
    }()

    static let supabaseAnonKey: String = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "PUBLIC_SUPABASE_ANON_KEY") as? String else {
            if isPreview {
                return "preview-anon-key"
            }
            fatalError("❌ Missing PUBLIC_SUPABASE_ANON_KEY in Info.plist")
        }
        return key
    }()

    // MARK: - RevenueCat Configuration
    static let revenueCatAPIKey: String = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "PUBLIC_REVENUECAT_IOS_API_KEY") as? String else {
            if isPreview {
                return "preview-revenuecat-key"
            }
            fatalError("❌ Missing PUBLIC_REVENUECAT_IOS_API_KEY in Info.plist")
        }
        return key
    }()

    // MARK: - Backend Configuration
    static let backendURL: String? = {
        Bundle.main.object(forInfoDictionaryKey: "PUBLIC_BACKEND_URL") as? String
    }()

    // MARK: - LiveKit Configuration
    static let liveKitURL: String? = {
        Bundle.main.object(forInfoDictionaryKey: "PUBLIC_LIVEKIT_URL") as? String
    }()

    // MARK: - PostHog Configuration (Optional)
    static let posthogAPIKey: String? = {
        Bundle.main.object(forInfoDictionaryKey: "EXPO_POSTHOG_API_KEY") as? String
    }()

    static let posthogProjectID: String? = {
        Bundle.main.object(forInfoDictionaryKey: "EXPO_POSTHOG_PROJECT_ID") as? String
    }()

    // MARK: - App Configuration
    static let appVersion: String = {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }()

    static let buildNumber: String = {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }()

    // MARK: - Development
    static let isDevelopment: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()

    // MARK: - Logging
    static func log(_ message: String, category: String = "App") {
        if isDevelopment {
            print("[\(category)] \(message)")
        }
    }
}