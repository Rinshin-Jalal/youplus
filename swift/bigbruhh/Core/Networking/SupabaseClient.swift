//
//  SupabaseClient.swift
//  BigBruh
//
//  Supabase client configuration matching nrn/lib/supabase.ts

import Foundation
import Supabase
import Auth
import PostgREST
import Realtime
import Storage

class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: Config.supabaseURL)!,
            supabaseKey: Config.supabaseAnonKey
        )

        Config.log("Supabase client initialized", category: "Supabase")
    }

    var auth: AuthClient {
        client.auth
    }

    var currentUser: Auth.User? {
        client.auth.currentUser
    }

    var currentSession: Auth.Session? {
        client.auth.currentSession
    }

    // MARK: - Database Helpers
    func from(_ table: String) -> PostgrestQueryBuilder {
        client.from(table)
    }
}

struct AuthUser: Codable {
    let id: String
    let email: String?
    let userMetadata: [String: AnyCodable]?

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case userMetadata = "user_metadata"
    }

    var name: String? {
        userMetadata?["name"]?.value as? String
    }
}

struct AuthSession: Codable {
    let accessToken: String
    let refreshToken: String?
    let expiresIn: Int
    let tokenType: String
    let user: AuthUser

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
        case user
    }
}

struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else {
            value = NSNull()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let bool as Bool:
            try container.encode(bool)
        case let dict as [String: Any]:
            let codableDict = dict.mapValues { AnyCodable($0) }
            try container.encode(codableDict)
        case let array as [Any]:
            let codableArray = array.map { AnyCodable($0) }
            try container.encode(codableArray)
        default:
            try container.encodeNil()
        }
    }
}
