//
//  DataStore.swift
//  bigbruhh
//
//  Local data caching and persistence layer
//  Caches API responses to reduce network calls and provide offline access
//

import Foundation

class DataStore {
    static let shared = DataStore()

    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // Cache TTL (Time To Live) in seconds
    private let defaultCacheTTL: TimeInterval = 300 // 5 minutes

    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        Config.log("DataStore initialized", category: "Cache")
    }

    // MARK: - Cache Entry

    private struct CacheEntry<T: Codable>: Codable {
        let data: T
        let timestamp: Date
        let ttl: TimeInterval

        var isExpired: Bool {
            Date().timeIntervalSince(timestamp) > ttl
        }
    }

    // MARK: - Generic Cache Methods

    /// Save data to cache with TTL
    func save<T: Codable>(_ data: T, forKey key: String, ttl: TimeInterval? = nil) {
        do {
            let entry = CacheEntry(
                data: data,
                timestamp: Date(),
                ttl: ttl ?? defaultCacheTTL
            )

            let encoded = try encoder.encode(entry)
            userDefaults.set(encoded, forKey: key)
            Config.log("Cached data for key: \(key)", category: "Cache")
        } catch {
            Config.log("Failed to cache data for key \(key): \(error)", category: "Cache")
        }
    }

    /// Retrieve data from cache if not expired
    func load<T: Codable>(forKey key: String, as type: T.Type) -> T? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }

        do {
            let entry = try decoder.decode(CacheEntry<T>.self, from: data)

            if entry.isExpired {
                Config.log("Cache expired for key: \(key)", category: "Cache")
                remove(forKey: key)
                return nil
            }

            Config.log("Cache hit for key: \(key)", category: "Cache")
            return entry.data
        } catch {
            Config.log("Failed to decode cache for key \(key): \(error)", category: "Cache")
            remove(forKey: key) // Remove corrupted cache
            return nil
        }
    }

    /// Remove cached data
    func remove(forKey key: String) {
        userDefaults.removeObject(forKey: key)
        Config.log("Removed cache for key: \(key)", category: "Cache")
    }

    /// Clear all cached data
    func clearAll() {
        let domain = Bundle.main.bundleIdentifier!
        userDefaults.removePersistentDomain(forName: domain)
        Config.log("Cleared all cache", category: "Cache")
    }

    // MARK: - Specific Cache Keys

    enum CacheKey {
        case identity(userId: String)
        case countdown(userId: String)
        case promises(userId: String)
        case callHistory(userId: String)
        case schedule(userId: String)

        var key: String {
            switch self {
            case .identity(let userId):
                return "cache_identity_\(userId)"
            case .countdown(let userId):
                return "cache_countdown_\(userId)"
            case .promises(let userId):
                return "cache_promises_\(userId)"
            case .callHistory(let userId):
                return "cache_calls_\(userId)"
            case .schedule(let userId):
                return "cache_schedule_\(userId)"
            }
        }
    }

    // MARK: - Convenience Methods for Specific Data Types

    /// Cache identity data
    func cacheIdentity(_ identity: IdentityData, userId: String) {
        save(identity, forKey: CacheKey.identity(userId: userId).key, ttl: 300) // 5 min
    }

    /// Load cached identity
    func loadIdentity(userId: String) -> IdentityData? {
        load(forKey: CacheKey.identity(userId: userId).key, as: IdentityData.self)
    }

    /// Cache countdown data
    func cacheCountdown(_ countdown: CountdownData, userId: String) {
        save(countdown, forKey: CacheKey.countdown(userId: userId).key, ttl: 60) // 1 min
    }

    /// Load cached countdown
    func loadCountdown(userId: String) -> CountdownData? {
        load(forKey: CacheKey.countdown(userId: userId).key, as: CountdownData.self)
    }

    /// Cache promises
    func cachePromises(_ promises: [Promise], userId: String) {
        save(promises, forKey: CacheKey.promises(userId: userId).key, ttl: 180) // 3 min
    }

    /// Load cached promises
    func loadPromises(userId: String) -> [Promise]? {
        load(forKey: CacheKey.promises(userId: userId).key, as: [Promise].self)
    }

    /// Cache call history
    func cacheCallHistory(_ calls: [CallLogEntry], userId: String) {
        save(calls, forKey: CacheKey.callHistory(userId: userId).key, ttl: 600) // 10 min
    }

    /// Load cached call history
    func loadCallHistory(userId: String) -> [CallLogEntry]? {
        load(forKey: CacheKey.callHistory(userId: userId).key, as: [CallLogEntry].self)
    }

    /// Cache schedule settings
    func cacheSchedule(_ schedule: ScheduleSettings, userId: String) {
        save(schedule, forKey: CacheKey.schedule(userId: userId).key, ttl: 1800) // 30 min
    }

    /// Load cached schedule
    func loadSchedule(userId: String) -> ScheduleSettings? {
        load(forKey: CacheKey.schedule(userId: userId).key, as: ScheduleSettings.self)
    }

    // MARK: - User-specific Cache Management

    /// Clear all cache for a specific user (e.g., on logout)
    func clearUserCache(userId: String) {
        remove(forKey: CacheKey.identity(userId: userId).key)
        remove(forKey: CacheKey.countdown(userId: userId).key)
        remove(forKey: CacheKey.promises(userId: userId).key)
        remove(forKey: CacheKey.callHistory(userId: userId).key)
        remove(forKey: CacheKey.schedule(userId: userId).key)
        Config.log("Cleared cache for user: \(userId)", category: "Cache")
    }
}

// MARK: - Cache-aware API Service Extension

extension APIService {
    /// Fetch identity with caching
    func fetchIdentityWithCache(userId: String, forceRefresh: Bool = false) async throws -> APIResponse<IdentityData> {
        // Check cache first if not forcing refresh
        if !forceRefresh, let cached = DataStore.shared.loadIdentity(userId: userId) {
            Config.log("Using cached identity data", category: "API")
            return APIResponse(success: true, data: cached, error: nil)
        }

        // Fetch from API
        let response = try await fetchIdentity(userId: userId)

        // Cache the result
        if let identity = response.data {
            DataStore.shared.cacheIdentity(identity, userId: userId)
        }

        return response
    }

    /// Fetch countdown with caching
    func fetchCountdownWithCache(userId: String, forceRefresh: Bool = false) async throws -> APIResponse<CountdownData> {
        if !forceRefresh, let cached = DataStore.shared.loadCountdown(userId: userId) {
            Config.log("Using cached countdown data", category: "API")
            return APIResponse(success: true, data: cached, error: nil)
        }

        let response = try await fetchCountdown(userId: userId)

        if let countdown = response.data {
            DataStore.shared.cacheCountdown(countdown, userId: userId)
        }

        return response
    }

    /// Fetch promises with caching
    func fetchPromisesWithCache(userId: String, forceRefresh: Bool = false) async throws -> APIResponse<[Promise]> {
        if !forceRefresh, let cached = DataStore.shared.loadPromises(userId: userId) {
            Config.log("Using cached promises data", category: "API")
            return APIResponse(success: true, data: cached, error: nil)
        }

        let response = try await fetchPromises(userId: userId)

        if let promises = response.data {
            DataStore.shared.cachePromises(promises, userId: userId)
        }

        return response
    }

    /// Fetch call history with caching
    func fetchCallHistoryWithCache(userId: String, forceRefresh: Bool = false) async throws -> APIResponse<[CallLogEntry]> {
        if !forceRefresh, let cached = DataStore.shared.loadCallHistory(userId: userId) {
            Config.log("Using cached call history", category: "API")
            return APIResponse(success: true, data: cached, error: nil)
        }

        let response = try await fetchCallHistory(userId: userId)

        if let calls = response.data {
            DataStore.shared.cacheCallHistory(calls, userId: userId)
        }

        return response
    }

    /// Fetch schedule with caching
    func fetchScheduleWithCache(userId: String, forceRefresh: Bool = false) async throws -> APIResponse<ScheduleSettings> {
        if !forceRefresh, let cached = DataStore.shared.loadSchedule(userId: userId) {
            Config.log("Using cached schedule data", category: "API")
            return APIResponse(success: true, data: cached, error: nil)
        }

        let response = try await fetchSchedule(userId: userId)

        if let schedule = response.data {
            DataStore.shared.cacheSchedule(schedule, userId: userId)
        }

        return response
    }
}
