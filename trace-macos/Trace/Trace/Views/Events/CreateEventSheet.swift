import SwiftUI
import PhotosUI
import AppKit
import MapKit

// ==========================================
// 1. MAIN EVENT SHEET (TRACE APP CORE)
// ==========================================
struct CreateEventSheet: View {
    var onDismiss: () -> Void
    var onSave: ((EventPayload) -> Void)? = nil
    var editingEvent: Event? = nil
    
    private let formLabelWidth: CGFloat = 110
    
    // Dynamic Header & Identity Bindings
    @State private var title: String
    @State private var description: String
    @State private var journal: String
    
    // Modern Clean Chronology Bindings
    @State private var year: Int
    @State private var monthSelection: Int
    @State private var daySelection: Int
    @State private var includeMonth: Bool
    @State private var includeDay: Bool
    
    // Exact Timestamp States
    @State private var includeTime: Bool = false
    @State private var hourSelection: Int = 12
    @State private var minuteSelection: Int = 0
    
    // Location
    @StateObject private var locationSearchService = LocationSearchService()
    @State private var locationName: String
    @State private var latitudeString: String
    @State private var longitudeString: String
    
    // Simplified PhotosPicker States — single cover image only
    @State private var selectedCoverItem: PhotosPickerItem? = nil
    @State private var coverImage: NSImage? = nil
    
    // Preferences & Flags
    @State private var anniversaryEnabled: Bool
    @State private var isVisibleInHighlights: Bool
    
    // Image cropper state
    @State private var pendingCropImage: NSImage? = nil
    @State private var showCropper: Bool = false
    
    init(onDismiss: @escaping () -> Void, onSave: ((EventPayload) -> Void)? = nil, editingEvent: Event? = nil) {
        self.onDismiss = onDismiss
        self.onSave = onSave
        self.editingEvent = editingEvent
        
        if let event = editingEvent {
            _title = State(initialValue: event.title)
            _description = State(initialValue: event.description ?? "")
            _journal = State(initialValue: event.journal ?? "")
            _year = State(initialValue: event.year)
            _monthSelection = State(initialValue: event.month ?? 5)
            _daySelection = State(initialValue: event.day ?? 1)
            _includeMonth = State(initialValue: event.month != nil)
            _includeDay = State(initialValue: event.day != nil)
            _locationName = State(initialValue: event.locationName ?? "")
            _latitudeString = State(initialValue: event.latitude.map { String($0) } ?? "")
            _longitudeString = State(initialValue: event.longitude.map { String($0) } ?? "")
            _anniversaryEnabled = State(initialValue: event.anniversaryEnabled)
            _isVisibleInHighlights = State(initialValue: event.isVisibleInHighlights)
            if let base64 = event.coverImage {
                _coverImage = State(initialValue: NSImage.fromBase64(base64))
            }
        } else {
            _title = State(initialValue: "")
            _description = State(initialValue: "")
            _journal = State(initialValue: "")
            _year = State(initialValue: 2026)
            _monthSelection = State(initialValue: 5)
            _daySelection = State(initialValue: 31)
            _includeMonth = State(initialValue: true)
            _includeDay = State(initialValue: true)
            _locationName = State(initialValue: "")
            _latitudeString = State(initialValue: "")
            _longitudeString = State(initialValue: "")
            _anniversaryEnabled = State(initialValue: false)
            _isVisibleInHighlights = State(initialValue: true)
        }
    }
    
    private var isEditing: Bool { editingEvent != nil }
    
    private var displayTitle: String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return isEditing ? "Edit Event" : "Create New Event"
        }
        return trimmed
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
                    CoverImagePicker(selectedItem: $selectedCoverItem, coverImage: $coverImage, onImagePicked: { image in
                        pendingCropImage = image
                        showCropper = true
                    })
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
        .overlay {
            if showCropper, let pending = pendingCropImage {
                ZStack {
                    Color.black.opacity(0.6)
                    
                    ImageCropperView(
                        sourceImage: pending,
                        aspectRatio: .circle,
                        onCrop: { cropped in
                            coverImage = cropped
                            showCropper = false
                            pendingCropImage = nil
                        },
                        onCancel: {
                            showCropper = false
                            pendingCropImage = nil
                            selectedCoverItem = nil
                        }
                    )
                    .frame(width: 440, height: 500)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.3), radius: 20)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showCropper)
    }
    
    private func saveMilestone() {
        let payload = EventPayload(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.isEmpty ? nil : description,
            year: year,
            month: includeMonth ? monthSelection : nil,
            day: (includeMonth && includeDay) ? daySelection : nil,
            locationName: locationName.isEmpty ? nil : locationName,
            latitude: Double(latitudeString),
            longitude: Double(longitudeString),
            coverImage: isEditing ? (coverImage?.toBase64() ?? "") : coverImage?.toBase64(),
            journal: journal.isEmpty ? nil : journal,
            anniversaryEnabled: anniversaryEnabled,
            isVisibleInHighlights: isVisibleInHighlights
        )
        onSave?(payload)
        onDismiss()
    }
}

#Preview {
    CreateEventSheet(onDismiss: {})
}
