import SwiftUI
import PhotosUI
import AppKit

struct CreateJourneySheet: View {
    var editingJourney: JourneyItem? = nil
    var onDismiss: () -> Void
    var onSave: (JourneyItem) -> Void
    
    // Form State
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var participants: [String] = []
    @State private var searchText: String = ""
    
    @State private var startDay: Int? = 1
    @State private var startMonth: Int? = 1
    @State private var startYear: Int? = 2026
    
    @State private var endDay: Int? = 1
    @State private var endMonth: Int? = 1
    @State private var endYear: Int? = 2026
    
    @State private var isOngoing: Bool = false
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var coverImage: NSImage? = nil
    
    private var displayTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "New Timeline" : title
    }
    
    var body: some View {
        SheetContainer(
            title: displayTitle,
            primaryLabel: editingJourney == nil ? "Create" : "Save",
            isPrimaryDisabled: title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            onDismiss: onDismiss,
            onPrimary: saveJourney
        ) {
            VStack(alignment: .leading, spacing: 12) {
                FormSectionHeader(text: "Visual Accent")
                
                CustomFormRow(label: "Cover Photo") {
                    CoverImagePicker(selectedItem: $selectedItem, coverImage: $coverImage)
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                FormSectionHeader(text: "GENERAL")
                
                CustomFormRow(label: "Title") {
                    TextField("Timeline Title", text: $title)
                        .styledInput()
                }
                
                CustomFormRow(label: "Description") {
                    TextField("Description...", text: $description, axis: .vertical)
                        .lineLimit(3...4)
                        .styledInput()
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                FormSectionHeader(text: "DATES")
                
                CustomFormRow(label: "Start Date") {
                    CustomDatePickerRow(day: $startDay, month: $startMonth, year: $startYear)
                }
                
                CustomFormRow(label: "End Date") {
                    CustomDatePickerRow(day: $endDay, month: $endMonth, year: $endYear)
                        .disabled(isOngoing)
                        .opacity(isOngoing ? 0.4 : 1.0)
                }
                
                CustomFormRow(label: "Ongoing?") {
                    HStack(spacing: 8) {
                        Toggle("", isOn: $isOngoing)
                            .toggleStyle(.switch)
                            .tint(AppTheme.roseGoldDark)
                            .labelsHidden()
                            .controlSize(.small)
                            .onChange(of: isOngoing) { _, ongoing in
                                if ongoing {
                                    endDay = nil
                                    endMonth = nil
                                    endYear = nil
                                } else {
                                    endDay = 1
                                    endMonth = 1
                                    endYear = 2026
                                }
                            }
                        
                        Text("Is this timeline ongoing?")
                            .font(AppTheme.subtitle)
                            .foregroundColor(AppTheme.primaryText.opacity(AppTheme.accentOpacity))
                        Spacer()
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                FormSectionHeader(text: "COLLABORATORS")
                
                CustomFormRow(label: "Search Users") {
                    VStack(alignment: .leading, spacing: 8) {
                        NativeSearchField(text: $searchText, placeholder: "Search by name or email...") {
                            let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmed.isEmpty && !participants.contains(trimmed) {
                                participants.append(trimmed)
                                searchText = ""
                            }
                        }
                        .frame(height: 22)
                        
                        if !participants.isEmpty {
                            FlowLayout(spacing: 6) {
                                ForEach(participants, id: \.self) { participant in
                                    HStack(spacing: 4) {
                                        Text(participant)
                                            .font(.system(size: 11, weight: .medium))
                                        Button(action: {
                                            participants.removeAll(where: { $0 == participant })
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 10))
                                                .foregroundColor(AppTheme.roseGoldDark.opacity(0.6))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(AppTheme.roseGoldLight.opacity(0.3))
                                    .foregroundColor(AppTheme.roseGoldDark)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                }
                            }
                            .padding(.top, 2)
                        }
                    }
                }
            }
        }
        .frame(width: 460, height: 560)
        .onAppear {
            if let journey = editingJourney {
                self.title = journey.title
                self.description = journey.description
                self.isOngoing = journey.isOngoing
            }
        }
    }
    
    private func saveJourney() {
        let startMonthStr = startMonth != nil ? Calendar.current.shortMonthSymbols[startMonth! - 1] : "01"
        let dateRangeStr = isOngoing ? "\(startMonthStr) \(startYear ?? 2026) — Ongoing" : "\(startMonthStr) \(startYear ?? 2026) — \(endMonth != nil ? Calendar.current.shortMonthSymbols[endMonth! - 1] : "01") \(endYear ?? 2026)"
        
        let item = JourneyItem(
            id: editingJourney?.id ?? UUID(),
            title: title,
            description: description,
            dateRangeString: dateRangeStr,
            collaboratorCount: participants.count,
            coverImageName: nil,
            isOngoing: isOngoing
        )
        onSave(item)
        onDismiss()
    }
}
