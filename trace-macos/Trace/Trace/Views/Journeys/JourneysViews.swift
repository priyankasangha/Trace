import SwiftUI

// ==========================================
// 1. DATA MODELS & STATE ARCHITECTURE
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
// 2. MAIN JOURNEYS DASHBOARD VIEW
// ==========================================
struct JourneysViews: View {
    @State private var journeys: [JourneyItem] = [
        JourneyItem(title: "Summer in Europe", description: "Exploring coastal cities, train transfers, and shared highlights.", dateRangeString: "05/12/2026 — Ongoing", collaboratorCount: 3, coverImageName: nil, isOngoing: true),
        JourneyItem(title: "Trace Architecture Shift", description: "Documenting the transition from full-stack JavaScript to native SwiftUI layout states.", dateRangeString: "04/01/2026 — 05/20/2026", collaboratorCount: 1, coverImageName: nil, isOngoing: false),
        JourneyItem(title: "Weekend Cabin Trip", description: "Off-grid micro-moments, campfire logs, and soundscapes.", dateRangeString: "05/24/2026 — 05/26/2026", collaboratorCount: 4, coverImageName: nil, isOngoing: false)
    ]
    
    // Stub logs to populate the new visual space functionally
    @State private var recentActivity: [ActivityLogItem] = [
        ActivityLogItem(message: "Updated Weekend Cabin Trip soundscapes", timestamp: "2m ago"),
        ActivityLogItem(message: "Shrey added comments to Architecture Shift", timestamp: "1h ago"),
        ActivityLogItem(message: "Added 3 new nodes to Summer in Europe", timestamp: "Yesterday")
    ]
    
    @State private var showCreateSheet: Bool = false
    @State private var footerHeartScale: CGFloat = 1.0
    
    private let columns = [
        GridItem(.adaptive(minimum: 240, maximum: 340), spacing: 20)
    ]
    
    var body: some View {
        HSplitView {
            
            // SIDE PANEL: MINIMALIST PROFILE PLATFORM
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.roseGoldLight.opacity(0.4))
                            .frame(width: 68, height: 68)
                        
                        Text("PS")
                            .font(.system(size: 20, weight: .medium, design: .serif))
                            .foregroundColor(AppTheme.roseGoldDark)
                    }
                    .overlay(Circle().stroke(AppTheme.roseGoldBase.opacity(0.5), lineWidth: AppTheme.thinLineWidth))
                    
                    VStack(spacing: 3) {
                        Text("Priyanka Sangha")
                            .font(AppTheme.title)
                            .foregroundColor(AppTheme.primaryText)
                        
                        Text("Architect & Creator")
                            .font(AppTheme.appTagline)
                            .tracking(AppTheme.placardTracking)
                            .foregroundColor(AppTheme.roseGoldDark)
                    }
                }
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
                .background(Color(nsColor: .controlBackgroundColor).opacity(0.4))
                .cornerRadius(12)
                .fineLineBorder()
                
                // QUICK ANALYTICS PLACARD
                VStack(alignment: .leading, spacing: 14) {
                    Text("OVERVIEW")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(AppTheme.titleTracking)
                        .foregroundColor(AppTheme.roseGoldDark)
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(AppTheme.roseGoldDark.opacity(0.5))
                            .frame(width: 4, height: 4)
                        Rectangle()
                            .fill(AppTheme.roseGoldLight.opacity(0.3))
                            .frame(height: AppTheme.thinLineWidth)
                        Circle()
                            .fill(AppTheme.roseGoldDark.opacity(0.5))
                            .frame(width: 4, height: 4)
                    }
                    .padding(.bottom, 2)
                    
                    HStack {
                        Text("Total Timelines")
                            .font(AppTheme.subtitle)
                            .foregroundColor(AppTheme.primaryText.opacity(AppTheme.accentOpacity))
                        Spacer()
                        Text("\(journeys.count)")
                            .font(AppTheme.body)
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.roseGoldDark)
                    }
                    
                    HStack {
                        Text("Active Contexts")
                            .font(AppTheme.subtitle)
                            .foregroundColor(AppTheme.primaryText.opacity(AppTheme.accentOpacity))
                        Spacer()
                        Text("1")
                            .font(AppTheme.body)
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.roseGoldDark)
                    }
                    
                    HStack {
                        Text("Shared Spaces")
                            .font(AppTheme.subtitle)
                            .foregroundColor(AppTheme.primaryText.opacity(AppTheme.accentOpacity))
                        Spacer()
                        Text("2")
                            .font(AppTheme.body)
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.roseGoldDark)
                    }
                    
                    HStack {
                        Text("Pinned Milestones")
                            .font(AppTheme.subtitle)
                            .foregroundColor(AppTheme.primaryText.opacity(AppTheme.accentOpacity))
                        Spacer()
                        Text("8")
                            .font(AppTheme.body)
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.roseGoldDark)
                    }
                    
                    HStack {
                        Text("Total Contributors")
                            .font(AppTheme.subtitle)
                            .foregroundColor(AppTheme.primaryText.opacity(AppTheme.accentOpacity))
                        Spacer()
                        Text("5")
                            .font(AppTheme.body)
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.roseGoldDark)
                    }
                }
                .padding(16)
                .background(AppTheme.roseGoldLight.opacity(0.08))
                .cornerRadius(12)
                
                // NEW ELEMENT: RECENT ACTIVITY LOG
                VStack(alignment: .leading, spacing: 12) {
                    Text("RECENT ACTIVITY")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(AppTheme.titleTracking)
                        .foregroundColor(AppTheme.roseGoldDark)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(recentActivity) { log in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(log.message)
                                    .font(.system(size: 11))
                                    .foregroundColor(AppTheme.primaryText.opacity(0.85))
                                    .lineLimit(1)
                                
                                Text(log.timestamp)
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(AppTheme.roseGoldDark.opacity(0.7))
                            }
                            
                            if log.id != recentActivity.last?.id {
                                Divider()
                                    .opacity(0.15)
                            }
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(nsColor: .controlBackgroundColor).opacity(0.2))
                .cornerRadius(12)
                .fineLineBorder()
                
                Spacer()
                
                // DEDICATION PLACARD FOOTER
                HStack(spacing: 6) {
                    Text("By Priyanka, For Shrey")
                        .font(AppTheme.dedicationPlacard)
                        .foregroundColor(AppTheme.primaryText.opacity(0.4))
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 9))
                        .foregroundColor(AppTheme.roseGoldDark.opacity(0.5))
                        .scaleEffect(footerHeartScale)
                }
                .padding(.bottom, 16)
                .onHover { hovering in
                    withAnimation(.interpolatingSpring(stiffness: 120, damping: 8)) {
                        footerHeartScale = hovering ? 1.3 : 1.0
                    }
                }
            }
            .padding(.top, AppTheme.windowTopSafetyPadding)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            .background(Color(nsColor: .windowBackgroundColor).opacity(0.95))
            .frame(minWidth: 260, idealWidth: 280, maxWidth: 400)
            
            // MAIN WORKSPACE CONTENT CANVAS
            VStack(spacing: 0) {
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
        .frame(minWidth: 900, minHeight: 600)
        .sheet(isPresented: $showCreateSheet) {
            CreateJourneySheet()
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
// 4. PREVIEW ANCHOR
// ==========================================
#Preview {
    JourneysViews()
}
