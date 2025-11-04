//
//  UserDefaultsManager.swift
//  BigBruh
//
//  AsyncStorage equivalent for Swift

import Foundation

enum UserDefaultsManager {
    private static let defaults = UserDefaults.standard

    // MARK: - Keys
    enum Keys {
        static let onboardingCompleted = "onboarding_completed"
        static let userId = "user_id"
        static let userEmail = "user_email"
        static let userName = "user_name"
        static let hasActiveSubscription = "has_active_subscription"
        static let lastCallTime = "last_call_time"
        static let currentStreak = "current_streak"
        static let onboardingData = "onboarding_data"
    }

    // MARK: - Generic Getters/Setters
    static func set<T>(_ value: T, forKey key: String) {
        defaults.set(value, forKey: key)
    }

    static func get<T>(_ key: String) -> T? {
        defaults.object(forKey: key) as? T
    }

    static func remove(forKey key: String) {
        defaults.removeObject(forKey: key)
    }

    // MARK: - Specific Helpers
    static var onboardingCompleted: Bool {
        get { defaults.bool(forKey: Keys.onboardingCompleted) }
        set { defaults.set(newValue, forKey: Keys.onboardingCompleted) }
    }

    static var userId: String? {
        get { defaults.string(forKey: Keys.userId) }
        set { defaults.set(newValue, forKey: Keys.userId) }
    }

    static var userEmail: String? {
        get { defaults.string(forKey: Keys.userEmail) }
        set { defaults.set(newValue, forKey: Keys.userEmail) }
    }

    static var userName: String? {
        get { defaults.string(forKey: Keys.userName) }
        set { defaults.set(newValue, forKey: Keys.userName) }
    }

    static var hasActiveSubscription: Bool {
        get { defaults.bool(forKey: Keys.hasActiveSubscription) }
        set { defaults.set(newValue, forKey: Keys.hasActiveSubscription) }
    }

    static var lastCallTime: Date? {
        get { defaults.object(forKey: Keys.lastCallTime) as? Date }
        set { defaults.set(newValue, forKey: Keys.lastCallTime) }
    }

    static var currentStreak: Int {
        get { defaults.integer(forKey: Keys.currentStreak) }
        set { defaults.set(newValue, forKey: Keys.currentStreak) }
    }

    // MARK: - Codable Storage
    static func setCodable<T: Codable>(_ value: T, forKey key: String) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)
        defaults.set(data, forKey: key)
    }

    static func getCodable<T: Codable>(_ key: String, as type: T.Type) throws -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        return try decoder.decode(type, from: data)
    }

    // MARK: - Clear All
    static func clearAll() {
        let domain = Bundle.main.bundleIdentifier!
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
    }
}