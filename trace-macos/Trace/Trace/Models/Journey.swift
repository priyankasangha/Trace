import Foundation

// ==========================================
// JOURNEY API MODEL (matches Prisma schema)
// ==========================================

struct Journey: Codable, Identifiable, Equatable {
    let id: Int
    var title: String
    var description: String?
    var coverPage: String?
    var completed: Bool
    var startYear: Int?
    var startMonth: Int?
    var startDay: Int?
    var endYear: Int?
    var endMonth: Int?
    var endDay: Int?
    var createdAt: String?
    var updatedAt: String?
    
    /// Converts API model to UI model for existing views
    func toItem() -> JourneyItem {
        let dateRangeStr: String
        if let sy = startYear {
            let startMonthStr = startMonth.map { Calendar.current.shortMonthSymbols[$0 - 1] } ?? ""
            if !completed, endYear == nil {
                dateRangeStr = "\(startMonthStr) \(sy) — Ongoing"
            } else if let ey = endYear {
                let endMonthStr = endMonth.map { Calendar.current.shortMonthSymbols[$0 - 1] } ?? ""
                dateRangeStr = "\(startMonthStr) \(sy) — \(endMonthStr) \(ey)"
            } else {
                dateRangeStr = "\(startMonthStr) \(sy)"
            }
        } else {
            dateRangeStr = completed ? "Completed" : "Ongoing"
        }
        
        return JourneyItem(
            title: title,
            description: description ?? "",
            dateRangeString: dateRangeStr,
            collaboratorCount: 0,
            coverImageName: coverPage,
            isOngoing: !completed,
            apiId: id
        )
    }
    
    static let mockJourneys: [Journey] = [
        Journey(
            id: 1,
            title: "Summer in Europe",
            description: "Exploring coastal cities, train transfers, and shared highlights.",
            coverPage: nil,
            completed: false,
            startYear: 2026, startMonth: 5, startDay: 12,
            endYear: nil, endMonth: nil, endDay: nil
        ),
        Journey(
            id: 2,
            title: "Trace Architecture Shift",
            description: "Documenting the transition from JavaScript to native SwiftUI states.",
            coverPage: nil,
            completed: true,
            startYear: 2026, startMonth: 4, startDay: 1,
            endYear: 2026, endMonth: 5, endDay: 20
        )
    ]
}

// ==========================================
// JOURNEY PAYLOAD (for create/update)
// ==========================================

struct JourneyPayload: Codable {
    var title: String
    var description: String?
    var coverPage: String?
    var completed: Bool
    var startYear: Int?
    var startMonth: Int?
    var startDay: Int?
    var endYear: Int?
    var endMonth: Int?
    var endDay: Int?
}
