import Foundation

struct JourneyItem: Identifiable {
    var id = UUID()
    let title: String
    let description: String
    let dateRangeString: String
    let collaboratorCount: Int
    let coverImageName: String?
    let isOngoing: Bool
    var apiId: Int? = nil
}
