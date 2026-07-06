import Foundation

// ==========================================
// EVENT API SERVICE
// ==========================================

class EventService {
    static let shared = EventService()
    
    private let baseURL = "http://127.0.0.1:3000/api/events"
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
    
    // MARK: - Fetch all events for a journey
    
    func fetchEvents(journeyId: Int) async throws -> [Event] {
        let url = URL(string: "\(baseURL)/\(journeyId)/events")!
        var request = URLRequest(url: url)
        applyAuth(to: &request)
        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)
        return try decoder.decode([Event].self, from: data)
    }
    
    // MARK: - Create a new event
    
    func createEvent(journeyId: Int, payload: EventPayload) async throws -> Event {
        let url = URL(string: "\(baseURL)/\(journeyId)/events")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        applyAuth(to: &request)
        request.httpBody = try encoder.encode(payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)
        return try decoder.decode(Event.self, from: data)
    }
    
    // MARK: - Update an existing event
    
    func updateEvent(journeyId: Int, eventId: Int, payload: EventPayload) async throws -> Event {
        let url = URL(string: "\(baseURL)/\(journeyId)/events/\(eventId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        applyAuth(to: &request)
        request.httpBody = try encoder.encode(payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)
        return try decoder.decode(Event.self, from: data)
    }
    
    // MARK: - Delete an event
    
    func deleteEvent(journeyId: Int, eventId: Int) async throws {
        let url = URL(string: "\(baseURL)/\(journeyId)/events/\(eventId)")!
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

// ==========================================
// API ERROR TYPES
// ==========================================

enum APIError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server."
        case .httpError(let code):
            return "Server returned status \(code)."
        }
    }
}
