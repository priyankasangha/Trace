import SwiftUI
import AppKit

// =========================================================================
// 1. ATTACHED DATA STRUCTURE STUB & MODELS
// =========================================================================
struct TimelineEventStub: Identifiable {
    let id = UUID()
    let category: String
    let title: String
    let dateString: String
    let description: String
    let imageName: String
}

// =========================================================================
// 2. BOUNDED SIDE ALIGNMENT ROW
// =========================================================================
struct BoundedVerticalMilestoneRow: View {
    let event: TimelineEventStub
    let isLeftAligned: Bool
    
    private let contentBlockWidth: CGFloat = 280
    private let horizontalLineLength: CGFloat = 60
    
    var body: some View {
        HStack(spacing: 0) {
            // COLUMN 1: LEFT WING AREA
            HStack(spacing: 0) {
                if isLeftAligned {
                    Spacer()
                    EventBlock(event: event)
                    
                    // Connected to the precise center-right edge of the block
                    Rectangle()
                        .fill(AppTheme.roseGoldLight.opacity(0.3))
                        .frame(width: horizontalLineLength, height: 1.5)
                } else {
                    Spacer()
                }
            }
            .frame(width: contentBlockWidth + horizontalLineLength)
            
            // COLUMN 2: CENTER SPINE ANCHOR NODE (Always vertically centered with connection lines)
            Circle()
                .fill(AppTheme.roseGoldBase)
                .frame(width: 8, height: 8)
                .background(Circle().stroke(AppTheme.roseGoldLight.opacity(0.5), lineWidth: 4))
                .frame(width: 2)
            
            // COLUMN 3: RIGHT WING AREA
            HStack(spacing: 0) {
                if !isLeftAligned {
                    // Connected to the precise center-left edge of the block
                    Rectangle()
                        .fill(AppTheme.roseGoldLight.opacity(0.3))
                        .frame(width: horizontalLineLength, height: 1.5)
                    
                    EventBlock(event: event)
                    Spacer()
                } else {
                    Spacer()
                }
            }
            .frame(width: contentBlockWidth + horizontalLineLength)
        }
        .frame(maxWidth: .infinity)
    }
}

// =========================================================================
// 3. TIMELINE CANVAS VIEW WITH SPLIT SIDEBAR LAYOUT
// =========================================================================
struct TimelineCanvasView: View {
    let journeyTitle: String
    let journeyDescription: String
    
    @State private var showFeedbackSheet: Bool = false
    @State private var showCreateEventSheet: Bool = false // Hooked up to the creation pipeline
    
    @State private var mockTotalTimelines = 3
    @State private var mockActivities: [ActivityLogItem] = [
        ActivityLogItem(message: "Updated Weekend Cabin Trip soundscapes", timestamp: "2m ago"),
        ActivityLogItem(message: "Shrey added comments to Architecture Shift", timestamp: "1h ago"),
        ActivityLogItem(message: "Added 3 new nodes to Summer in Europe", timestamp: "Yesterday")
    ]
    
    @State private var sampleEvents: [TimelineEventStub] = [
        TimelineEventStub(
            category: "ARCHITECTURE",
            title: "Project Conception Blueprint",
            dateString: "MAY 01, 2026",
            description: "Initial outline of architecture layers written down on paper.",
            imageName: "doc.text.image"
        ),
        TimelineEventStub(
            category: "DATABASE",
            title: "Database Schema Finalized",
            dateString: "MAY 31, 2026",
            description: "Mapped out all core models and attributes natively in Prisma.",
            imageName: "externaldrive.badge.checkmark"
        ),
        TimelineEventStub(
            category: "INTERFACE",
            title: "First Fluid UI Prototype",
            dateString: "JUN 12, 2026",
            description: "Successfully rendered fluid macOS windows and basic sheets.",
            imageName: "window.shade.closed"
        )
    ]
    
    var body: some View {
        HSplitView {
            // UNIFIED BRANDING SIDEBAR PLATFORM
            AppSidebarView(
                totalTimelinesCount: mockTotalTimelines,
                recentActivities: mockActivities,
                showFeedbackSheet: $showFeedbackSheet
            )
            
            // DYNAMIC TIMELINE WORKSPACE CANVAS
            VStack(spacing: 0) {
                // CLEANED HERO IDENTITY HEADER
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(journeyTitle)
                                .font(.system(size: 38, weight: .bold, design: .serif))
                                .foregroundColor(AppTheme.roseGoldDark)
                            
                            if !journeyDescription.isEmpty {
                                Text(journeyDescription)
                                    .font(.system(size: 13, weight: .medium, design: .serif))
                                    .italic()
                                    .foregroundColor(AppTheme.primaryText.opacity(0.55))
                            }
                        }
                        
                        Spacer()
                        
                        // NEW MILESTONE ACTION TRIGGER
                        Button(action: { showCreateEventSheet = true }) {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                    .font(.system(size: 11, weight: .bold))
                                Text("NEW MILESTONE")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .tracking(0.5)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(AppTheme.roseGoldDark)
                            .cornerRadius(20)
                            .shadow(color: AppTheme.roseGoldDark.opacity(0.15), radius: 6, x: 0, y: 3)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // ULTRA-MINIMAL METADATA STRIP
                    HStack {
                        Text("ENGINEERING CANVAS METADATA PLATFORM")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(AppTheme.primaryText.opacity(0.35))
                            .tracking(1.5)
                        
                        Spacer()
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 32)
                .background(AppTheme.cardBackground.ignoresSafeArea())
                .overlay(
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(AppTheme.roseGoldLight.opacity(0.2))
                            .frame(height: 1)
                    }
                )
                
                // TIMELINE CANVAS STREAM
                ScrollView(.vertical, showsIndicators: true) {
                    ZStack(alignment: .top) {
                        Rectangle()
                            .fill(AppTheme.roseGoldLight.opacity(0.3))
                            .frame(width: 1.5)
                            .padding(.vertical, 40)
                        
                        VStack(spacing: 60) {
                            ForEach(Array(sampleEvents.enumerated()), id: \.offset) { index, event in
                                let isLeftAligned = index % 2 == 0
                                BoundedVerticalMilestoneRow(event: event, isLeftAligned: isLeftAligned)
                            }
                        }
                        .padding(.vertical, 40)
                    }
                    .frame(maxWidth: .infinity)
                }
                .background(AppTheme.primaryBackground.opacity(0.98))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 1150, minHeight: 700)
        // PRESENTING YOUR EXTERNAL SHEET DIRECTLY
        .sheet(isPresented: $showCreateEventSheet) {
            CreateEventSheet()
        }
        .sheet(isPresented: $showFeedbackSheet) {
            VStack(spacing: 20) {
                Text("Shrey's Feedback Corner")
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundColor(AppTheme.roseGoldDark)
                Text("Review space pending context pipelines.")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.primaryText.opacity(0.6))
                Button("Dismiss") { showFeedbackSheet.toggle() }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
            }
            .padding(40)
            .frame(width: 400, height: 250)
        }
    }
}

// =========================================================================
// 4. CANVAS RENDERING PREVIEW WINDOW
// =========================================================================
#Preview {
    TimelineCanvasView(
        journeyTitle: "Trace Architecture",
        journeyDescription: "By Priyanka, For Shrey — An immersive canvas mapping core architectural sprints."
    )
    .frame(width: 1300, height: 850)
}
