//
//  APIService.swift
//  BigBruh
//
//  API service for backend calls matching nrn/lib/api.ts

import Foundation
import Auth

enum APIError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    case unauthorized
    case networkError(Error)
    case subscriptionRequired

    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .serverError(let message):
            return "Server error: \(message)"
        case .unauthorized:
            return "Unauthorized - please sign in"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .subscriptionRequired:
            return "Active subscription required"
        }
    }
}

struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let error: String?
}

class APIService {
    static let shared = APIService()

    private let baseURL: String
    private let session: URLSession

    private init() {
        // Require backend URL from config; do not hardcode fallbacks
        guard let url = Config.backendURL, !url.isEmpty else {
            fatalError("❌ Missing PUBLIC_BACKEND_URL in Info.plist. Set it to your backend base URL.")
        }
        self.baseURL = url

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)

        Config.log("APIService initialized with base URL: \(baseURL)", category: "API")
    }

    // MARK: - Generic Request
    func request<T: Codable>(
        _ endpoint: String,
        method: HTTPMethod = .get,
        body: [String: Any]? = nil
    ) async throws -> APIResponse<T> {
        let full = "\(baseURL)\(endpoint)"
        Config.log("Request → \(full)", category: "API")
        guard let url = URL(string: full) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add auth token if available
        if let session = SupabaseManager.shared.currentSession {
            request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
            Config.log("🔑 Added auth token to request: \(endpoint)", category: "API")
        } else {
            Config.log("❌ No auth session available for request: \(endpoint)", category: "API")
        }

        // Add body if present
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.serverError("Invalid response")
            }

            if httpResponse.statusCode == 401 {
                throw APIError.unauthorized
            }

            if httpResponse.statusCode >= 400 {
                throw APIError.serverError("HTTP \(httpResponse.statusCode)")
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601

            // Log raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                Config.log("Response: \(responseString)", category: "API")
            }

            let apiResponse = try decoder.decode(APIResponse<T>.self, from: data)

            Config.log("Response decoded - success: \(apiResponse.success), hasData: \(apiResponse.data != nil), error: \(apiResponse.error ?? "none")", category: "API")

            return apiResponse

        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    // MARK: - Convenience Methods
    func get<T: Codable>(_ endpoint: String) async throws -> APIResponse<T> {
        try await request(endpoint, method: .get)
    }

    func post<T: Codable>(_ endpoint: String, body: [String: Any]) async throws -> APIResponse<T> {
        try await request(endpoint, method: .post, body: body)
    }

    func put<T: Codable>(_ endpoint: String, body: [String: Any]) async throws -> APIResponse<T> {
        try await request(endpoint, method: .put, body: body)
    }

    func delete<T: Codable>(_ endpoint: String) async throws -> APIResponse<T> {
        try await request(endpoint, method: .delete)
    }

    // MARK: - Identity Endpoints

    /// Fetch user identity and stats
    /// GET /api/identity/:userId
    func fetchIdentity(userId: String) async throws -> APIResponse<IdentityData> {
        Config.log("Fetching identity for user: \(userId)", category: "API")
        return try await get("/api/identity/\(userId)")
    }

    /// Update user identity
    /// PUT /api/identity/:userId
    func updateIdentity(userId: String, updates: [String: Any]) async throws -> APIResponse<IdentityData> {
        Config.log("Updating identity for user: \(userId)", category: "API")
        return try await put("/api/identity/\(userId)", body: updates)
    }

    /// Get identity statistics
    /// GET /api/identity/stats/:userId
    func fetchIdentityStats(userId: String) async throws -> APIResponse<[String: AnyCodableValue]> {
        return try await get("/api/identity/stats/\(userId)")
    }

    // MARK: - Call Endpoints

    /// Get call configuration for 11Labs
    /// GET /call/config/:userId/:callType
    func getCallConfig(userId: String, callType: String) async throws -> APIResponse<CallConfigResponse> {
        Config.log("Getting call config for \(callType) call", category: "API")
        return try await get("/call/config/\(userId)/\(callType)")
    }


    // MARK: - Onboarding Endpoints

    /// Push completed onboarding data to backend
    /// POST /onboarding/v3/complete
    func pushOnboardingData(request: OnboardingCompleteRequest) async throws -> APIResponse<IdentityExtraction> {
        Config.log("Pushing onboarding data for user", category: "API")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]

        return try await post("/onboarding/v3/complete", body: json)
    }

    // MARK: - VOIP Token Endpoints

    /// Register VOIP push token
    /// POST /token-init-push
    func registerVOIPToken(request: VOIPTokenRequest) async throws -> APIResponse<[String: AnyCodableValue]> {
        Config.log("Registering VOIP token", category: "API")

        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]

        return try await post("/token-init-push", body: json)
    }

    // MARK: - Health Check

    /// Test API connectivity
    /// GET /test
    func testConnection() async throws -> APIResponse<[String: AnyCodableValue]> {
        Config.log("Testing API connection", category: "API")
        return try await get("/test")
    }
}

// MARK: - HTTP Methods
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

// MARK: - Empty Response
struct EmptyResponse: Codable {}
