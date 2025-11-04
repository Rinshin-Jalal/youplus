//
//  DataCacheManager.swift
//  bigbruhh
//
//  Data caching service with 5-minute TTL and pull-to-refresh support
//

import Foundation
import Combine

class DataCacheManager: ObservableObject {
    static let shared = DataCacheManager()
    
    private let cacheTTL: TimeInterval = 5 * 60 // 5 minutes
    private var cache: [String: CachedData] = [:]
    
    private init() {}
    
    // MARK: - Cache Operations
    
    func get<T: Codable>(_ key: String, type: T.Type) -> T? {
        guard let cachedData = cache[key] else { return nil }
        
        // Check if data is still valid
        if Date().timeIntervalSince(cachedData.timestamp) < cacheTTL {
            return cachedData.data as? T
        } else {
            // Data is stale, remove from cache
            cache.removeValue(forKey: key)
            return nil
        }
    }
    
    func set<T: Codable>(_ key: String, data: T) {
        cache[key] = CachedData(data: data, timestamp: Date())
        Config.log("📦 Cached data for key: \(key)", category: "Cache")
    }
    
    func invalidate(_ key: String) {
        cache.removeValue(forKey: key)
        Config.log("🗑️ Invalidated cache for key: \(key)", category: "Cache")
    }
    
    func invalidateAll() {
        cache.removeAll()
        Config.log("🗑️ Cleared all cache", category: "Cache")
    }
    
    func isStale(_ key: String) -> Bool {
        guard let cachedData = cache[key] else { return true }
        return Date().timeIntervalSince(cachedData.timestamp) >= cacheTTL
    }
    
    // MARK: - Refresh Operations
    
    func forceRefresh(_ key: String) {
        invalidate(key)
        Config.log("🔄 Force refresh requested for key: \(key)", category: "Cache")
    }
}

// MARK: - Cached Data Structure

private struct CachedData {
    let data: Any
    let timestamp: Date
}

// MARK: - Cache Keys

extension DataCacheManager {
    enum CacheKeys {
        static let identity = "identity"
        static let callHistory = "call_history"
        // brutalReality removed (bloat elimination)
        static let promises = "promises"
        static let schedule = "schedule"
        static let countdown = "countdown"
        static let voiceClips = "voice_clips"
    }
}
