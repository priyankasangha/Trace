import SwiftUI
import AppKit

// =========================================================================
// TIMELINE CANVAS VIEW WITH SPLIT SIDEBAR LAYOUT
//
// TimelineEventStub -> Models/TimelineEventStub.swift
// BoundedVerticalEventRow, EventRowContainer -> Views/Events/Components/EventRow.swift
// EditDeleteButtons -> Views/Components/EditDeleteButtons.swift
// DeleteConfirmationModifier -> Views/Components/DeleteConfirmationModifier.swift
// =========================================================================
struct TimelineCanvasView: View {
    let journeyTitle: String
    let journeyDescription: String
    var onBack: (() -> Void)? = nil
    
    @State private var showEventSheet: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State private var showFeedbackSheet: Bool = false
    @State private var selectedEvent: TimelineEventStub? = nil
    @State private var focusedEventId: UUID? = nil
    
    private func dismissEventSheet() {
        showEventSheet = false
        selectedEvent = nil
        focusedEventId = nil
    }
    
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
            imageName: "macmini"
        ),
        TimelineEventStub(
            category: "INTERFACE",
            title: "First Fluid UI Prototype",
            dateString: "JUN 12, 2026",
            description: "Successfully rendered fluid macOS windows and basic sheets.",
            imageName: "ipad"
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
                // IDENTITY HEADER
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top) {
                        if let onBack {
                            Button(action: onBack) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(AppTheme.roseGoldDark)
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 10)
                        }
                        
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
                        
                        // ACTION TRIGGER
                        Button(action: {
                            selectedEvent = nil
                            showEventSheet = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                    .font(.system(size: 11, weight: .bold))
                                Text("NEW EVENT")
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
                            ForEach(Array(sampleEvents.enumerated()), id: \.element.id) { item in
                                EventRowContainer(
                                    event: item.element,
                                    isLeftAligned: item.offset % 2 == 0,
                                    isFocused: focusedEventId == item.element.id,
                                    onDoubleTap: {
                                        withAnimation {
                                            if focusedEventId == item.element.id {
                                                focusedEventId = nil
                                            } else {
                                                focusedEventId = item.element.id
                                            }
                                        }
                                    },
                                    onEdit: {
                                        selectedEvent = item.element
                                        showEventSheet = true
                                    },
                                    onDelete: {
                                        selectedEvent = item.element
                                        showDeleteConfirmation = true
                                    }
                                )
                            }
                        }
                        .padding(.vertical, 40)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation { focusedEventId = nil }
                    }
                }
                .background(AppTheme.primaryBackground.opacity(0.98))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 1150, minHeight: 700)
        
        .modifier(SheetOverlayModifier(isPresented: $showEventSheet) {
            CreateEventSheet(onDismiss: { dismissEventSheet() })
        })
        .modifier(DeleteConfirmationModifier(
            isPresented: $showDeleteConfirmation,
            selectedItem: $selectedEvent,
            itemLabel: "Event",
            displayName: { $0.title },
            onDelete: { event in
                sampleEvents.removeAll(where: { $0.id == event.id })
                focusedEventId = nil
            }
        ))
        .modifier(SheetOverlayModifier(isPresented: $showFeedbackSheet) {
            FeedbackCornerSheet(onDismiss: { showFeedbackSheet = false })
        })
    }
}

// =========================================================================
// CANVAS PREVIEW
// =========================================================================
#Preview {
    TimelineCanvasView(
        journeyTitle: "Trace Architecture",
        journeyDescription: "By Priyanka, For Shrey — An immersive canvas mapping core architectural sprints."
    )
    .frame(width: 1300, height: 850)
}

