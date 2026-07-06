import Foundation

// ==========================================
// JOURNEY API SERVICE
// ==========================================

class JourneyService {
    static let shared = JourneyService()
    
    private let baseURL = "http://127.0.0.1:3000/api/journeys"
    var authToken: String?
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        return d
    }()
    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        return e
    }()
    
    private init() {}
    
    // MARK: - Fetch all journeys
    
    func fetchJourneys() async throws -> [Journey] {
        let url = URL(string: baseURL)!
        var request = URLRequest(url: url)
        applyAuth(to: &request)
        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)
        return try decoder.decode([Journey].self, from: data)
    }
    
    // MARK: - Create a new journey
    
    func createJourney(payload: JourneyPayload) async throws -> Journey {
        let url = URL(string: baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        applyAuth(to: &request)
        request.httpBody = try encoder.encode(payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)
        return try decoder.decode(Journey.self, from: data)
    }
    
    // MARK: - Update an existing journey
    
    func updateJourney(journeyId: Int, payload: JourneyPayload) async throws -> Journey {
        let url = URL(string: "\(baseURL)/\(journeyId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        applyAuth(to: &request)
        request.httpBody = try encoder.encode(payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)
        return try decoder.decode(Journey.self, from: data)
    }
    
    // MARK: - Delete a journey
    
    func deleteJourney(journeyId: Int) async throws {
        let url = URL(string: "\(baseURL)/\(journeyId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        applyAuth(to: &request)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response, allowNoContent: true)
    }
    
    // MARK: - Helpers
    
    private func applyAuth(to request: inout URLRequest) {
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
    
    private func validateResponse(_ response: URLResponse, allowNoContent: Bool = false) throws {
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        if allowNoContent && http.statusCode == 204 { return }
        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpError(statusCode: http.statusCode)
        }
    }
}
