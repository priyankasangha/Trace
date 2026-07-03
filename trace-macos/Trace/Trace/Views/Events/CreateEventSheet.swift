import SwiftUI
import PhotosUI
import AppKit
import MapKit

// ==========================================
// 1. MAIN EVENT SHEET (TRACE APP CORE)
// ==========================================
struct CreateEventSheet: View {
    var onDismiss: () -> Void
    
    private let formLabelWidth: CGFloat = 110
    
    // Dynamic Header & Identity Bindings
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var journal: String = ""
    
    // Modern Clean Chronology Bindings
    @State private var year: Int = 2026
    @State private var monthSelection: Int = 5
    @State private var daySelection: Int = 31
    @State private var includeMonth: Bool = true
    @State private var includeDay: Bool = true
    
    // Exact Timestamp States
    @State private var includeTime: Bool = false
    @State private var hourSelection: Int = 12
    @State private var minuteSelection: Int = 0
    
    // Location
    @StateObject private var locationSearchService = LocationSearchService()
    @State private var locationName: String = ""
    @State private var latitudeString: String = ""
    @State private var longitudeString: String = ""
    
    // Simplified PhotosPicker States — single cover image only
    @State private var selectedCoverItem: PhotosPickerItem? = nil
    @State private var coverImage: NSImage? = nil
    
    // Preferences & Flags
    @State private var anniversaryEnabled: Bool = false
    @State private var isVisibleInHighlights: Bool = true
    
    private var displayTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Create New Event" : title
    }
    
    var body: some View {
        SheetContainer(
            title: displayTitle,
            primaryLabel: "Save",
            isPrimaryDisabled: title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            onDismiss: onDismiss,
            onPrimary: saveMilestone
        ) {
            // SECTION 1: VISUAL ACCENT MANAGEMENT
            VStack(alignment: .leading, spacing: 12) {
                FormSectionHeader(text: "MEDIA ACCENTS")
                
                CustomFormRow(label: "Cover Image", labelWidth: formLabelWidth) {
                    CoverImagePicker(selectedItem: $selectedCoverItem, coverImage: $coverImage)
                }
            }
            
            // SECTION 2: IDENTITY DETAILS
            VStack(alignment: .leading, spacing: 12) {
                FormSectionHeader(text: "GENERAL IDENTITY")
                
                CustomFormRow(label: "Title", labelWidth: formLabelWidth) {
                    TextField("Enter event title...", text: $title)
                        .styledInput()
                }
                
                CustomFormRow(label: "Description", labelWidth: formLabelWidth) {
                    TextField("Brief subtitle summaries...", text: $description, axis: .vertical)
                        .lineLimit(2...3)
                        .styledInput()
                }
            }
            
            // SECTION 3: NATIVE DROPDOWN CHRONOLOGY
            VStack(alignment: .leading, spacing: 12) {
                FormSectionHeader(text: "CHRONOLOGY")
                
                CustomFormRow(label: "Timeline Context", labelWidth: formLabelWidth) {
                    HStack(spacing: 6) {
                        Picker("", selection: $year) {
                            ForEach(1900...2100, id: \.self) { y in
                                Text(String(y)).tag(y)
                            }
                        }
                        .pickerStyle(.menu)
                        .fixedSize()
                        
                        Toggle("Month", isOn: $includeMonth)
                            .toggleStyle(.checkbox)
                        
                        if includeMonth {
                            Picker("", selection: $monthSelection) {
                                ForEach(1...12, id: \.self) { m in
                                    Text(Calendar.current.shortMonthSymbols[m - 1]).tag(m)
                                }
                            }
                            .pickerStyle(.menu)
                            .fixedSize()
                            .transition(.opacity)
                            
                            Toggle("Day", isOn: $includeDay)
                                .toggleStyle(.checkbox)
                            
                            if includeDay {
                                Picker("", selection: $daySelection) {
                                    ForEach(1...31, id: \.self) { d in
                                        Text(String(format: "%02d", d)).tag(d)
                                    }
                                }
                                .pickerStyle(.menu)
                                .fixedSize()
                                .transition(.opacity)
                            }
                        }
                    }
                    .labelsHidden()
                    .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.85), value: includeMonth)
                    .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.85), value: includeDay)
                }
                
                CustomFormRow(label: "Exact Clock", labelWidth: formLabelWidth) {
                    HStack(spacing: 8) {
                        Toggle("Enable Time", isOn: $includeTime)
                            .toggleStyle(.checkbox)
                        
                        if includeTime {
                            HStack(spacing: 4) {
                                Picker("", selection: $hourSelection) {
                                    ForEach(0..<24, id: \.self) { h in
                                        Text(String(format: "%02d", h)).tag(h)
                                    }
                                }
                                .pickerStyle(.menu)
                                .fixedSize()
                                
                                Text(":")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(AppTheme.roseGoldDark)
                                
                                Picker("", selection: $minuteSelection) {
                                    ForEach(0..<60, id: \.self) { m in
                                        Text(String(format: "%02d", m)).tag(m)
                                    }
                                }
                                .pickerStyle(.menu)
                                .fixedSize()
                            }
                            .labelsHidden()
                            .transition(.opacity)
                        }
                    }
                    .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.85), value: includeTime)
                }
            }
            
            // SECTION 4: LOCATION
            VStack(alignment: .leading, spacing: 12) {
                FormSectionHeader(text: "LOCATION")
                
                MapLocationPicker(
                    searchService: locationSearchService,
                    locationName: $locationName,
                    latitudeString: $latitudeString,
                    longitudeString: $longitudeString
                )
            }
            
            // SECTION 5: LONG-FORM JOURNAL
            VStack(alignment: .leading, spacing: 12) {
                FormSectionHeader(text: "LONG-FORM JOURNAL")
                
                TextField("Write your personal retrospective updates here...", text: $journal, axis: .vertical)
                    .lineLimit(4...6)
                    .styledInput()
            }
            
            // SECTION 6: AUTOMATION CONTROLS
            VStack(alignment: .leading, spacing: 14) {
                Toggle(isOn: $anniversaryEnabled) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Enable Anniversary Celebrations")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.primaryText)
                        Text("Triggers custom event confetti popups inside the grid.")
                            .font(.system(size: 10))
                            .foregroundColor(AppTheme.primaryText.opacity(0.6))
                    }
                }
                .toggleStyle(.switch)
                .tint(AppTheme.roseGoldDark)
                
                Divider().opacity(0.15)
                
                Toggle(isOn: $isVisibleInHighlights) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Visible in Highlights Grid")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.primaryText)
                        Text("Toggles filtering automatically for custom summaries.")
                            .font(.system(size: 10))
                            .foregroundColor(AppTheme.primaryText.opacity(0.6))
                    }
                }
                .toggleStyle(.switch)
                .tint(AppTheme.roseGoldDark)
            }
            .padding(14)
            .background(AppTheme.roseGoldLight.opacity(0.06))
            .cornerRadius(8)
        }
        .frame(width: 480, height: 700)
    }
    
    private func saveMilestone() {
        onDismiss()
    }
}

#Preview {
    CreateEventSheet(onDismiss: {})
}
