import Foundation

// ==========================================
// API EVENT MODEL (Matches backend Prisma schema)
// ==========================================

struct Event: Codable, Identifiable, Equatable {
    let id: Int
    var title: String
    var description: String?
    var year: Int
    var month: Int?
    var day: Int?
    var locationName: String?
    var latitude: Double?
    var longitude: Double?
    var coverImage: String?
    var journal: String?
    var anniversaryEnabled: Bool
    var lastCelebratedYear: Int?
    var isVisibleInHighlights: Bool
    var journeyId: Int
    var createdAt: String?
    var updatedAt: String?
    
    // Formatted date string for display (e.g. "MAY 01, 2026")
    var dateString: String {
        var parts: [String] = []
        if let m = month, (1...12).contains(m) {
            parts.append(Calendar.current.shortMonthSymbols[m - 1].uppercased())
        }
        if let d = day {
            parts.append(String(format: "%02d,", d))
        }
        parts.append(String(year))
        return parts.joined(separator: " ")
    }
    
    // Convert to TimelineEventStub for existing UI components
    func toStub() -> TimelineEventStub {
        TimelineEventStub(
            id: UUID(),
            category: "",
            title: title,
            dateString: dateString,
            description: description ?? "",
            imageName: "calendar.circle",
            coverImageData: coverImage
        )
    }
    
    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.id == rhs.id
    }
}

// ==========================================
// EVENT PAYLOAD (For create/update requests)
// ==========================================

struct EventPayload: Codable {
    var title: String
    var description: String?
    var year: Int
    var month: Int?
    var day: Int?
    var locationName: String?
    var latitude: Double?
    var longitude: Double?
    var coverImage: String?
    var journal: String?
    var anniversaryEnabled: Bool
    var isVisibleInHighlights: Bool
}

// ==========================================
// MOCK DATA
// ==========================================

extension Event {
    static let mockEvents: [Event] = [
        Event(
            id: 1,
            title: "Project Conception Blueprint",
            description: "Initial outline of architecture layers written down on paper.",
            year: 2026, month: 5, day: 1,
            anniversaryEnabled: false,
            isVisibleInHighlights: true,
            journeyId: 1
        ),
        Event(
            id: 2,
            title: "Database Schema Finalized",
            description: "Mapped out all core models and attributes natively in Prisma.",
            year: 2026, month: 5, day: 31,
            anniversaryEnabled: false,
            isVisibleInHighlights: true,
            journeyId: 1
        ),
        Event(
            id: 3,
            title: "First Fluid UI Prototype",
            description: "Successfully rendered fluid macOS windows and basic sheets.",
            year: 2026, month: 6, day: 12,
            anniversaryEnabled: false,
            isVisibleInHighlights: true,
            journeyId: 1
        )
    ]
}
