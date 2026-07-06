import SwiftUI

// ==========================================
// DATA MODEL (Local Activity Log Context)
// ==========================================
struct ActivityLogItem: Identifiable {
    let id = UUID()
    let message: String
    let timestamp: String
}

// ==========================================
// MAIN JOURNEYS INTERFACE
// ==========================================
struct JourneysViews: View {
    let recentActivities: [ActivityLogItem]
    var onOpenJourney: (JourneyItem) -> Void
    
    // API-backed journeys + their UI representations
    @State private var apiJourneys: [Journey] = []
    @State private var journeyItems: [JourneyItem] = []
    @State private var itemToJourneyId: [UUID: Int] = [:]
    
    @State private var showCreateSheet: Bool = false
    @State private var searchText: String = ""
    @State private var isSearchActive: Bool = false
    
    @State private var selectedJourney: JourneyItem? = nil
    @State private var editingJourney: Journey? = nil
    @State private var showDeleteConfirmation: Bool = false
    @State private var showFeedbackSheet: Bool = false
    
    private func refreshItems() {
        journeyItems = apiJourneys.map { $0.toItem() }
        itemToJourneyId = Dictionary(uniqueKeysWithValues: zip(journeyItems.map(\.id), apiJourneys.map(\.id)))
    }
    
    private func dismissCreateSheet() {
        showCreateSheet = false
        selectedJourney = nil
        editingJourney = nil
    }
    
    private let columns = [
        GridItem(.adaptive(minimum: 240, maximum: 340), spacing: 20)
    ]
    
    private var filteredJourneys: [JourneyItem] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return journeyItems }
        return journeyItems.filter {
            $0.title.localizedCaseInsensitiveContains(trimmed) ||
            $0.description.localizedCaseInsensitiveContains(trimmed)
        }
    }
    
    var body: some View {
        HSplitView {
            AppSidebarView(
                totalTimelinesCount: journeyItems.count,
                recentActivities: recentActivities,
                showFeedbackSheet: $showFeedbackSheet
            )
            
            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Journeys")
                            .font(AppTheme.largeTitle)
                            .foregroundColor(AppTheme.roseGoldDark)
                        Text("Your collection of mapped timelines and interactive contexts.")
                            .font(AppTheme.body)
                            .foregroundColor(AppTheme.primaryText.opacity(AppTheme.mutedTextOpacity))
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        JourneySearchCapsule(searchText: $searchText, isActive: $isSearchActive)
                        
                        // FIXED: Clears selection explicitly so the sheet re-evaluates as a fresh creation modal
                        Button(action: {
                            selectedJourney = nil
                            editingJourney = nil
                            showCreateSheet = true
                        }) {
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
                                JourneyCardView(
                                    journey: journey,
                                    onOpen: { onOpenJourney(journey) },
                                    onEdit: {
                                        selectedJourney = journey
                                        if let apiId = itemToJourneyId[journey.id] {
                                            editingJourney = apiJourneys.first(where: { $0.id == apiId })
                                        }
                                        showCreateSheet = true
                                    },
                                    onDelete: {
                                        selectedJourney = journey
                                        showDeleteConfirmation = true
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 32)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.primaryBackground)
            .contentShape(Rectangle())
            .onTapGesture {
                if isSearchActive {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                        isSearchActive = false
                        searchText = ""
                    }
                }
            }
        }
        .modifier(DeleteConfirmationModifier(
            isPresented: $showDeleteConfirmation,
            selectedItem: $selectedJourney,
            itemLabel: "Journey",
            displayName: { $0.title },
            onDelete: { journey in
                if let apiId = itemToJourneyId[journey.id] {
                    Task {
                        do {
                            try await JourneyService.shared.deleteJourney(journeyId: apiId)
                            apiJourneys.removeAll(where: { $0.id == apiId })
                            refreshItems()
                        } catch {
                            print("Delete journey failed: \(error.localizedDescription)")
                        }
                    }
                }
            }
        ))
        .modifier(SheetOverlayModifier(isPresented: $showCreateSheet) {
            CreateJourneySheet(
                editingJourney: editingJourney,
                onDismiss: { dismissCreateSheet() },
                onSave: { payload in
                    Task {
                        if let existing = editingJourney {
                            do {
                                let updated = try await JourneyService.shared.updateJourney(journeyId: existing.id, payload: payload)
                                if let idx = apiJourneys.firstIndex(where: { $0.id == existing.id }) {
                                    apiJourneys[idx] = updated
                                }
                                refreshItems()
                            } catch {
                                print("Update journey failed: \(error.localizedDescription)")
                            }
                        } else {
                            do {
                                let created = try await JourneyService.shared.createJourney(payload: payload)
                                apiJourneys.append(created)
                                refreshItems()
                            } catch {
                                print("Create journey failed: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            )
        })
        .modifier(SheetOverlayModifier(isPresented: $showFeedbackSheet) {
            FeedbackCornerSheet(onDismiss: { showFeedbackSheet = false })
        })
        .task {
            do {
                apiJourneys = try await JourneyService.shared.fetchJourneys()
            } catch {
                print("Failed to load journeys, using mock data: \(error.localizedDescription)")
                apiJourneys = Journey.mockJourneys
            }
            refreshItems()
        }
    }
}

private struct JourneySearchCapsule: View {
    @Binding var searchText: String
    @Binding var isActive: Bool
    
    private let collapsedWidth: CGFloat = 30
    private let expandedWidth: CGFloat = 240
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isActive ? AppTheme.roseGoldDark : AppTheme.roseGoldDark.opacity(0.7))
                .frame(width: 14)
            
            if isActive {
                NativeSearchField(
                    text: $searchText,
                    placeholder: "Search journeys...",
                    chrome: .plain,
                    autoFocus: true,
                    onCommit: {},
                    onFocusLost: { collapse() }
                )
                .frame(height: 20)
                .transition(.opacity)
                
                Button(action: { collapse() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.primaryText.opacity(0.3))
                }
                .buttonStyle(.plain)
                .transition(.opacity)
            }
        }
        .padding(.horizontal, isActive ? 12 : 8)
        .frame(width: isActive ? expandedWidth : collapsedWidth, height: 30, alignment: .leading)
        .background(AppTheme.roseGoldLight.opacity(isActive ? 0.18 : 0.1))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(AppTheme.roseGoldLight.opacity(isActive ? 0.4 : 0.25), lineWidth: AppTheme.thinLineWidth)
        )
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: isActive)
        .onTapGesture {
            if !isActive {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                    isActive = true
                }
            }
        }
        .help("Search Journeys")
    }
    
    private func collapse() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
            isActive = false
            searchText = ""
        }
    }
}
