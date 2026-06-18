import SwiftUI

// ==========================================
// 1. DATA MODELS
// ==========================================
struct JourneyItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let dateRangeString: String
    let collaboratorCount: Int
    let coverImageName: String?
    let isOngoing: Bool
}

struct ActivityLogItem: Identifiable {
    let id = UUID()
    let message: String
    let timestamp: String
}

// ==========================================
// 2. MAIN JOURNEYS INTERFACE (WITH SIDEBAR)
// ==========================================
struct JourneysViews: View {
    let journeys: [JourneyItem]
    let recentActivities: [ActivityLogItem] // Passed down for the sidebar
    
    @Binding var showCreateSheet: Bool
    @Binding var showFeedbackSheet: Bool // Bound to the sidebar's interactive card
    
    private let columns = [
        GridItem(.adaptive(minimum: 240, maximum: 340), spacing: 20)
    ]
    
    var body: some View {
        HSplitView {
            // SIDEBAR PLACEMENT (LEFT)
            AppSidebarView(
                totalTimelinesCount: journeys.count,
                recentActivities: recentActivities,
                showFeedbackSheet: $showFeedbackSheet
            )
            
            // MAIN CANVAS WORKSPACE (RIGHT)
            VStack(spacing: 0) {
                // TOP HEADER CONTROL ROW
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Journeys")
                            .font(AppTheme.largeTitle)
                            .foregroundColor(AppTheme.roseGoldDark)
                        Text("Your collection of mapped timelines and interactive contexts.")
                            .font(AppTheme.body)
                            .foregroundColor(AppTheme.primaryText.opacity(AppTheme.mutedTextOpacity))
                    }
                    
                    Spacer()
                    
                    Button(action: { showCreateSheet.toggle() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 11, weight: .bold))
                            Text("New Journey")
                                .font(AppTheme.subtitle)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(AppTheme.roseGoldDark)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 32)
                .padding(.top, AppTheme.windowTopSafetyPadding + 12)
                .padding(.bottom, 24)
                
                // GRID CANVAS
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVGrid(columns: columns, spacing: 24) {
                        ForEach(journeys) { journey in
                            JourneyCardView(journey: journey)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.primaryBackground)
        }
    }
}

// ==========================================
// 3. EDITORIAL JOURNEY DISPLAY CARD
// ==========================================
struct JourneyCardView: View {
    let journey: JourneyItem
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                if let _ = journey.coverImageName {
                    Color.gray
                } else {
                    LinearGradient(
                        colors: [AppTheme.roseGoldLight.opacity(0.6), AppTheme.roseGoldBase.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                
                if journey.isOngoing {
                    Text("Ongoing")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(AppTheme.roseGoldDark)
                        .clipShape(Capsule())
                        .padding(10)
                }
            }
            .frame(height: 115)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(journey.title)
                    .font(AppTheme.title)
                    .foregroundColor(AppTheme.primaryText)
                    .lineLimit(1)
                
                Text(journey.description)
                    .font(AppTheme.body)
                    .foregroundColor(AppTheme.primaryText.opacity(0.7))
                    .lineLimit(2)
                    .frame(height: 34, alignment: .top)
                
                SkinnyDivider()
                    .padding(.vertical, 4)
                
                HStack {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(AppTheme.roseGoldDark.opacity(0.7))
                            .frame(width: 5, height: 5)
                        
                        Text(journey.dateRangeString)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(AppTheme.primaryText.opacity(AppTheme.accentOpacity))
                    
                    Spacer()
                    
                    HStack(spacing: 3) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 10))
                        Text("\(journey.collaboratorCount)")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(AppTheme.roseGoldDark)
                }
            }
            .padding(16)
            .background(Color(nsColor: .controlBackgroundColor))
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .fineLineBorder()
        .scaleEffect(isHovered ? 1.015 : 1.0)
        .shadow(color: Color.black.opacity(isHovered ? 0.04 : 0.0), radius: 8, x: 0, y: 4)
        .animation(.easeOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// ==========================================
// 4. COMMON VIEW EXTENSIONS
// ==========================================
extension View {
    func fineLineBorder(color: Color = AppTheme.primaryText.opacity(0.1)) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color, lineWidth: AppTheme.thinLineWidth)
        )
    }
}

// ==========================================
// 5. PREVIEW CANVAS ANCHOR
// ==========================================
#Preview {
    JourneysViews(
        journeys: [
            JourneyItem(title: "Summer in Europe", description: "Exploring coastal cities, train transfers, and shared highlights.", dateRangeString: "05/12/2026 — Ongoing", collaboratorCount: 3, coverImageName: nil, isOngoing: true),
            JourneyItem(title: "Trace Architecture Shift", description: "Documenting the transition from JavaScript to native SwiftUI states.", dateRangeString: "04/01/2026 — 05/20/2026", collaboratorCount: 1, coverImageName: nil, isOngoing: false)
        ],
        recentActivities: [
            ActivityLogItem(message: "Updated timeline constraints", timestamp: "Just now"),
            ActivityLogItem(message: "Shared 'Summer in Europe' context", timestamp: "2 hours ago")
        ],
        showCreateSheet: .constant(false),
        showFeedbackSheet: .constant(false)
    )
    .frame(width: 950, height: 650)
}
