//
//  AnalyticsService.swift
//  BigBruh
//
//  Mixpanel analytics service wrapper for tracking events, revenue, and user properties
//

import Foundation
import Mixpanel

class AnalyticsService {
    static let shared = AnalyticsService()
    
    private var mixpanelInstance: MixpanelInstance?
    private var sessionStartTime: Date?
    private var currentSessionId: String?
    
    private init() {
        // Initialize Mixpanel if token is available
        if let token = Config.mixpanelToken, !Config.isPreview {
            mixpanelInstance = Mixpanel.initialize(token: token, trackAutomaticEvents: true)
            Config.log("✅ Mixpanel initialized", category: "Analytics")
        } else {
            Config.log("⚠️ Mixpanel not initialized (preview mode or no token)", category: "Analytics")
        }
    }
    
    // MARK: - Event Tracking
    
    func track(event: String, properties: [String: Any]? = nil) {
        guard let mixpanel = mixpanelInstance else {
            Config.log("📊 [Analytics] Event: \(event) - Properties: \(properties ?? [:])", category: "Analytics")
            return
        }
        
        var eventProperties: [String: MixpanelType] = [:]
        if let props = properties {
            eventProperties = props.mapValues { value -> MixpanelType in
                // Convert Any to MixpanelType
                if let stringValue = value as? String {
                    return stringValue
                } else if let numberValue = value as? NSNumber {
                    return numberValue
                } else if let boolValue = value as? Bool {
                    return boolValue
                } else if let dateValue = value as? Date {
                    return dateValue
                }
                return String(describing: value)
            }
        }
        
        eventProperties["app_version"] = Config.appVersion
        eventProperties["build_number"] = Config.buildNumber
        
        mixpanel.track(event: event, properties: eventProperties)
        Config.log("📊 Tracked: \(event)", category: "Analytics")
    }
    
    // MARK: - Revenue Tracking
    
    func trackRevenue(
        amount: Double,
        productId: String,
        currency: String = "USD",
        properties: [String: Any]? = nil
    ) {
        guard let mixpanel = mixpanelInstance else {
            Config.log("💰 [Analytics] Revenue: \(amount) \(currency) - Product: \(productId)", category: "Analytics")
            return
        }
        
        var revenueProperties: [String: MixpanelType] = [
            "$revenue": amount,
            "product_id": productId,
            "currency": currency
        ]
        
        if let props = properties {
            let convertedProps = props.mapValues { value -> MixpanelType in
                if let stringValue = value as? String {
                    return stringValue
                } else if let numberValue = value as? NSNumber {
                    return numberValue
                } else if let boolValue = value as? Bool {
                    return boolValue
                } else if let dateValue = value as? Date {
                    return dateValue
                }
                return String(describing: value)
            }
            revenueProperties.merge(convertedProps) { _, new in new }
        }
        
        mixpanel.track(event: "subscription_purchased", properties: revenueProperties)
        
        // Increment total revenue user property
        incrementUserProperty("total_revenue", by: amount)
        
        // Update last purchase date
        setUserProperties([
            "last_purchase_date": ISO8601DateFormatter().string(from: Date())
        ])
        
        Config.log("💰 Tracked revenue: \(amount) \(currency) for product \(productId)", category: "Analytics")
    }
    
    // MARK: - User Identification
    
    func identify(userId: String) {
        guard let mixpanel = mixpanelInstance else {
            Config.log("👤 [Analytics] Identify: \(userId)", category: "Analytics")
            return
        }
        
        mixpanel.identify(distinctId: userId)
        Config.log("👤 Identified user: \(userId)", category: "Analytics")
    }
    
    // MARK: - User Properties
    
    func setUserProperties(_ properties: [String: Any]) {
        guard let mixpanel = mixpanelInstance else {
            Config.log("👤 [Analytics] Set properties: \(properties)", category: "Analytics")
            return
        }
        
        // Convert properties to MixpanelType and register them
        // registerSuperProperties automatically merges with existing super properties
        var convertedProperties: [String: MixpanelType] = [:]
        
        for (key, value) in properties {
            if let stringValue = value as? String {
                convertedProperties[key] = stringValue
            } else if let numberValue = value as? NSNumber {
                convertedProperties[key] = numberValue
            } else if let boolValue = value as? Bool {
                convertedProperties[key] = boolValue
            } else if let dateValue = value as? Date {
                convertedProperties[key] = dateValue
            } else {
                convertedProperties[key] = String(describing: value)
            }
        }
        
        mixpanel.registerSuperProperties(convertedProperties)
        Config.log("👤 Set user properties: \(properties.keys.joined(separator: ", "))", category: "Analytics")
    }
    
    func incrementUserProperty(_ property: String, by value: Double) {
        guard let mixpanel = mixpanelInstance else {
            Config.log("👤 [Analytics] Increment \(property) by \(value)", category: "Analytics")
            return
        }
        
        mixpanel.people.increment(property: property, by: value)
        Config.log("👤 Incremented \(property) by \(value)", category: "Analytics")
    }
    
    // MARK: - Screen Tracking
    
    func trackScreen(_ screenName: String, properties: [String: Any]? = nil) {
        var screenProperties = properties ?? [:]
        screenProperties["screen_name"] = screenName
        
        track(event: "screen_viewed", properties: screenProperties)
    }
    
    // MARK: - Session Tracking
    
    func trackSessionStart() {
        let sessionId = UUID().uuidString
        currentSessionId = sessionId
        sessionStartTime = Date()
        
        // Check if this is first session
        let isFirstSession = UserDefaults.standard.bool(forKey: "mixpanel_first_session") == false
        if isFirstSession {
            UserDefaults.standard.set(true, forKey: "mixpanel_first_session")
        }
        
        track(event: "app_opened", properties: [
            "session_id": sessionId,
            "is_first_session": isFirstSession
        ])
    }
    
    func trackSessionEnd() {
        guard let startTime = sessionStartTime else { return }
        
        let duration = Date().timeIntervalSince(startTime)
        
        track(event: "app_backgrounded", properties: [
            "session_id": currentSessionId ?? "unknown",
            "session_duration": duration
        ])
        
        sessionStartTime = nil
        currentSessionId = nil
    }
    
    // MARK: - Reset
    
    func reset() {
        guard let mixpanel = mixpanelInstance else { return }
        
        mixpanel.reset()
        Config.log("🔄 Analytics reset (user logged out)", category: "Analytics")
    }
}

