import SwiftUI

// ==========================================
// 1. DATA MODEL
//    (JourneyItem lives in Views/Journeys/Models/JourneyItem.swift —
//    ActivityLogItem stays here since it's small and only meaningfully
//    used alongside this view and AppSidebarView)
// ==========================================
struct ActivityLogItem: Identifiable {
    let id = UUID()
    let message: String
    let timestamp: String
}

// ==========================================
// 2. MAIN JOURNEYS INTERFACE (WITH SIDEBAR)
//
// JourneyCardView -> Views/Journeys/Components/JourneyCardView.swift
// fineLineBorder() -> already defined in your design system file
// (the FineLineBorder ViewModifier) — not redefined here
// ==========================================
struct JourneysViews: View {
    let journeys: [JourneyItem]
    let recentActivities: [ActivityLogItem] // Passed down for the sidebar
    
    @Binding var showCreateSheet: Bool
    @Binding var showFeedbackSheet: Bool // Bound to the sidebar's interactive card
    
    @State private var searchText: String = ""
    @State private var isSearchActive: Bool = false
    
    private let columns = [
        GridItem(.adaptive(minimum: 240, maximum: 340), spacing: 20)
    ]
    
    private var filteredJourneys: [JourneyItem] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return journeys }
        return journeys.filter {
            $0.title.localizedCaseInsensitiveContains(trimmed) ||
            $0.description.localizedCaseInsensitiveContains(trimmed)
        }
    }
    
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
                    
                    HStack(spacing: 10) {
                        if isSearchActive {
                            HStack(spacing: 6) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppTheme.primaryText.opacity(0.4))
                                
                                NativeSearchField(text: $searchText, placeholder: "Search journeys...") {}
                                    .frame(width: 200, height: 22)
                                
                                Button(action: {
                                    withAnimation(.easeOut(duration: 0.15)) {
                                        isSearchActive = false
                                        searchText = ""
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(AppTheme.primaryText.opacity(0.3))
                                        .font(.system(size: 12))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .fineLineBorder()
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        } else {
                            Button(action: {
                                withAnimation(.easeOut(duration: 0.15)) {
                                    isSearchActive = true
                                }
                            }) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(AppTheme.roseGoldDark)
                                    .frame(width: 28, height: 28)
                            }
                            .buttonStyle(.plain)
                            .help("Search Journeys")
                        }
                        
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
                }
                .padding(.horizontal, 32)
                .padding(.top, AppTheme.windowTopSafetyPadding + 12)
                .padding(.bottom, 24)
                
                // GRID CANVAS
                ScrollView(.vertical, showsIndicators: true) {
                    if filteredJourneys.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 22))
                                .foregroundColor(AppTheme.primaryText.opacity(0.25))
                            Text("No journeys match \"\(searchText)\"")
                                .font(AppTheme.body)
                                .foregroundColor(AppTheme.primaryText.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 80)
                    } else {
                        LazyVGrid(columns: columns, spacing: 24) {
                            ForEach(filteredJourneys) { journey in
                                JourneyCardView(journey: journey)
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 32)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.primaryBackground)
        }
    }
}

// ==========================================
// 3. PREVIEW CANVAS ANCHOR
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
