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
                activeTimelinesCount: journeyItems.filter(\.isOngoing).count,
                recentActivities: recentActivities,
                showFeedbackSheet: $showFeedbackSheet,
                isInteractionDisabled: showCreateSheet || showDeleteConfirmation || showFeedbackSheet
            )
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Timelines")
                                .font(.system(size: 38, weight: .bold, design: .serif))
                                .foregroundColor(AppTheme.roseGoldDark)
                            Text("Your mapped moments")
                                .font(.system(size: 13, weight: .medium, design: .serif))
                                .italic()
                                .foregroundColor(AppTheme.primaryText.opacity(0.55))
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            JourneySearchCapsule(searchText: $searchText, isActive: $isSearchActive)
                            
                            Button(action: {
                                selectedJourney = nil
                                editingJourney = nil
                                showCreateSheet = true
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 11, weight: .bold))
                                    Text("NEW TIMELINE")
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
                    }
                    

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
                
                ScrollView(.vertical, showsIndicators: true) {
                    if journeyItems.isEmpty {
                        EmptyStatePlaceholder(
                            icon: "heart.fill",
                            title: "Start a Timeline Today",
                            subtitle: "Click anywhere to begin mapping moments that matter.",
                            onTap: {
                                selectedJourney = nil
                                editingJourney = nil
                                showCreateSheet = true
                            }
                        )
                    } else if filteredJourneys.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 22))
                                .foregroundColor(AppTheme.primaryText.opacity(0.25))
                            Text("No timelines match \"\(searchText)\"")
                                .font(AppTheme.body)
                                .foregroundColor(AppTheme.primaryText.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 80)
                    } else {
                        LazyVGrid(columns: columns, spacing: 24) {
                            ForEach(filteredJourneys) { journey in
                                JourneyCardView(
                                    isInteractionDisabled: showCreateSheet || showDeleteConfirmation || showFeedbackSheet,
                                    journey: journey,
                                    onOpen: { onOpenJourney(journey) },
                                    onEdit: {
                                        selectedJourney = journey
                                        if let apiId = itemToJourneyId[journey.id] {
                                            editingJourney = apiJourneys.first(where: { $0.id == apiId })
                                        }
                                        DispatchQueue.main.async {
                                            showCreateSheet = true
                                        }
                                    },
                                    onDelete: {
                                        selectedJourney = journey
                                        showDeleteConfirmation = true
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 24)
                        .padding(.bottom, 32)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
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
            itemLabel: "Timeline",
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
        .overlay {
            if showCreateSheet || showDeleteConfirmation || showFeedbackSheet {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
            }
        }
        .overlay {
            if showCreateSheet {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture { dismissCreateSheet() }
                    
                    CreateJourneySheet(
                        editingJourney: editingJourney,
                        onDismiss: { dismissCreateSheet() },
                        onSave: { payload in
                            let existingJourney = editingJourney
                            Task {
                                if let existing = existingJourney {
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
                    .id(editingJourney?.id)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.25), radius: 20)
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showCreateSheet)
        .modifier(SheetOverlayModifier(isPresented: $showFeedbackSheet) {
            FeedbackCornerSheet(onDismiss: { showFeedbackSheet = false })
        })
        .task {
            do {
                apiJourneys = try await JourneyService.shared.fetchJourneys()
            } catch {
                print("Failed to load journeys: \(error.localizedDescription)")
                apiJourneys = []
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
                    placeholder: "Search timelines...",
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
        .help("Search Timelines")
    }
    
    private func collapse() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
            isActive = false
            searchText = ""
        }
    }
}
