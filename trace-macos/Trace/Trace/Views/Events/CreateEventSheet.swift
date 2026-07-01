import SwiftUI
import PhotosUI
import AppKit

// ==========================================
// 1. MAIN EVENT SHEET (TRACE APP CORE)
// ==========================================
struct CreateEventSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    // Explicit alignment metrics for form fields
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
    
    // Geolocation Context Strings
    @State private var locationName: String = ""
    @State private var latitudeString: String = ""
    @State private var longitudeString: String = ""
    
    // Simplified PhotosPicker States — single cover image only
    @State private var selectedCoverItem: PhotosPickerItem? = nil
    @State private var coverImage: NSImage? = nil
    
    // Preferences & Flags
    @State private var anniversaryEnabled: Bool = false
    @State private var isVisibleInHighlights: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            
            // HEADER SECTION
            HStack(spacing: 12) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.roseGoldDark)
                }
                .buttonStyle(.plain)
                
                Text(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "New Event Milestone" : title)
                    .font(AppTheme.title)
                    .foregroundColor(AppTheme.roseGoldDark)
                    .lineLimit(1)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 24)
            
            // SCROLLABLE CONTENT CANVAS
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 26) {
                    
                    // SECTION 1: VISUAL ACCENT MANAGEMENT
                    VStack(alignment: .leading, spacing: 12) {
                        FormSectionHeader(text: "MEDIA ACCENTS")
                        
                        FormRow(label: "Cover Image", labelWidth: formLabelWidth) {
                            HStack(spacing: 12) {
                                PhotosPicker(selection: $selectedCoverItem, matching: .images, photoLibrary: .shared()) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "photo.on.rectangle.angled")
                                        Text(coverImage == nil ? "Upload Cover Artwork" : "Change Cover")
                                    }
                                    .font(AppTheme.subtitle)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(AppTheme.roseGoldDark)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                }
                                .buttonStyle(.plain)
                                .onChange(of: selectedCoverItem) { _, newItem in
                                    Task {
                                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                                           let nsImage = NSImage(data: data) {
                                            await MainActor.run {
                                                self.coverImage = nsImage
                                            }
                                        }
                                    }
                                }
                                
                                if let coverImage = coverImage {
                                    Image(nsImage: coverImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 32)
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 4)
                                                .stroke(AppTheme.primaryText.opacity(0.08), lineWidth: AppTheme.thinLineWidth)
                                        )
                                    
                                    Button(action: {
                                        self.coverImage = nil
                                        self.selectedCoverItem = nil
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(AppTheme.primaryText.opacity(0.3))
                                            .font(.system(size: 14))
                                    }
                                    .buttonStyle(.plain)
                                }
                                Spacer()
                            }
                        }
                    }
                    
                    // SECTION 2: IDENTITY DETAILS
                    VStack(alignment: .leading, spacing: 12) {
                        FormSectionHeader(text: "GENERAL IDENTITY")
                        
                        FormRow(label: "Title", labelWidth: formLabelWidth) {
                            TextField("Enter milestone title...", text: $title)
                                .styledInput()
                        }
                        
                        FormRow(label: "Description", labelWidth: formLabelWidth) {
                            TextField("Brief subtitle summaries...", text: $description, axis: .vertical)
                                .lineLimit(2...3)
                                .styledInput()
                        }
                    }
                    
                    // SECTION 3: NATIVE DROPDOWN CHRONOLOGY
                    VStack(alignment: .leading, spacing: 12) {
                        FormSectionHeader(text: "CHRONOLOGY")
                        
                        FormRow(label: "Timeline Context", labelWidth: formLabelWidth) {
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
                        
                        FormRow(label: "Exact Clock", labelWidth: formLabelWidth) {
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
                    
                    // SECTION 4: LONG-FORM JOURNAL ENTRY
                    VStack(alignment: .leading, spacing: 12) {
                        FormSectionHeader(text: "LONG-FORM JOURNAL")
                        
                        TextField("Write your personal retrospective updates here...", text: $journal, axis: .vertical)
                            .lineLimit(4...6)
                            .styledInput()
                    }
                    
                    // SECTION 5: AUTOMATION CONTROLS
                    VStack(alignment: .leading, spacing: 14) {
                        Toggle(isOn: $anniversaryEnabled) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Enable Anniversary Celebrations")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(AppTheme.primaryText)
                                Text("Triggers custom milestone confetti popups inside the grid.")
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
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            
            Divider().opacity(0.2)
            
            // BOTTOM ACTION DRAWER
            HStack(spacing: 12) {
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .keyboardShortcut(.cancelAction)
                
                Button("Save Milestone") {
                    saveMilestone()
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.roseGoldDark)
                .keyboardShortcut(.defaultAction)
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(AppTheme.primaryBackground)
        }
        .frame(width: 480, height: 620)
        .background(AppTheme.primaryBackground)
        .preferredColorScheme(.light)
    }
    
    private func saveMilestone() {
        dismiss()
    }
}

#Preview {
    CreateEventSheet()
}
