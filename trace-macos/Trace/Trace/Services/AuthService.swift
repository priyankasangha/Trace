import Foundation

// ==========================================
// AUTH SERVICE
// ==========================================

class AuthService {
    static let shared = AuthService()
    
    private let baseURL = "http://127.0.0.1:3000/api/auth"
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    private init() {}
    
    /// Sends the Apple identity token to the backend, which verifies it
    /// and returns a long-lived JWT for subsequent API calls.
    func authenticateWithApple(identityToken: String) async throws -> AuthResponse {
        let url = URL(string: "\(baseURL)/apple")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = AppleAuthPayload(identityToken: identityToken)
        request.httpBody = try encoder.encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpError(statusCode: http.statusCode)
        }
        
        return try decoder.decode(AuthResponse.self, from: data)
    }
}

// MARK: - Models

struct AppleAuthPayload: Codable {
    let identityToken: String
}

struct AuthResponse: Codable {
    let token: String
}
