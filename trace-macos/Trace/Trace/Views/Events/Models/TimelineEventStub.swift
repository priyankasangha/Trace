import Foundation

struct TimelineEventStub: Identifiable, Equatable {
    let id: UUID
    let category: String
    let title: String
    let dateString: String
    let description: String
    let imageName: String
    
    init(id: UUID = UUID(), category: String, title: String, dateString: String, description: String, imageName: String) {
        self.id = id
        self.category = category
        self.title = title
        self.dateString = dateString
        self.description = description
        self.imageName = imageName
    }
}
