//
//  User.swift
//  BigBruh
//
//  User model matching Supabase auth.users schema

import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String?
    let name: String?
    let createdAt: Date?
    let updatedAt: Date?
    let revenuecatCustomerId: String?
    let subscriptionStatus: String?
    let timezone: String?
    let callWindowStart: String?
    let callWindowTimezone: String?
    let voiceCloneId: String?
    let pushToken: String?
    let onboardingCompleted: Bool?
    let onboardingCompletedAt: Date?
    let scheduleChangeCount: Int?
    let voiceRecloneCount: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case revenuecatCustomerId = "revenuecat_customer_id"
        case subscriptionStatus = "subscription_status"
        case timezone
        case callWindowStart = "call_window_start"
        case callWindowTimezone = "call_window_timezone"
        case voiceCloneId = "voice_clone_id"
        case pushToken = "push_token"
        case onboardingCompleted = "onboarding_completed"
        case onboardingCompletedAt = "onboarding_completed_at"
        case scheduleChangeCount = "schedule_change_count"
        case voiceRecloneCount = "voice_reclone_count"
    }

    var displayName: String {
        name ?? email?.components(separatedBy: "@").first ?? "User"
    }
}

// MARK: - Grade Enum
enum Grade: String, Codable, CaseIterable {
    case a = "A"
    case b = "B"
    case c = "C"
    case f = "F"

    var color: Color {
        switch self {
        case .a: return .gradeA
        case .b: return .gradeB
        case .c: return .gradeC
        case .f: return .gradeF
        }
    }

    var emoji: String {
        switch self {
        case .a: return "🔥"
        case .b: return "💪"
        case .c: return "⚠️"
        case .f: return "💀"
        }
    }

    var message: String {
        switch self {
        case .a: return "UNSTOPPABLE"
        case .b: return "SOLID PROGRESS"
        case .c: return "BARELY PASSING"
        case .f: return "COMPLETE FAILURE"
        }
    }
}

// MARK: - User Status for Home Screen
struct UserStatus: Codable {
    let streak: Int
    let grade: Grade
    let nextCallTime: Date?
    let lastCallCompleted: Date?
    let hasActiveSubscription: Bool

    var isCallDue: Bool {
        guard let nextCall = nextCallTime else { return false }
        return Date() >= nextCall
    }

    var timeUntilNextCall: TimeInterval? {
        guard let nextCall = nextCallTime else { return nil }
        return nextCall.timeIntervalSince(Date())
    }
}

import SwiftUI
