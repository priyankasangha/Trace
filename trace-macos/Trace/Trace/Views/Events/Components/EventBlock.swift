import SwiftUI

struct EventBlock: View {
    let event: TimelineEventStub
    
    // Clean call initializer pattern
    init(event: TimelineEventStub) {
        self.event = event
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            // Extracted Graphic Asset Anchor
            TimelineEventCircle(imageName: event.imageName, coverImageData: event.coverImageData)
            
            // Extracted Core Data Panel
            TimelineEventCard(
                category: event.category,
                title: event.title,
                dateString: event.dateString,
                description: event.description
            )
        }
        .frame(width: 280)
    }
}
#Preview {
    EventBlock(event: TimelineEventStub(
        category: "Milestone",
        title: "First Commit",
        dateString: "Jan 15, 2026",
        description: "The very first commit that started it all.",
        imageName: "star.fill"
    ))
    .padding(40)
}

