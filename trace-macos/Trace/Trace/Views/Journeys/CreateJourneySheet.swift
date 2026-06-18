import SwiftUI
import PhotosUI
import AppKit

// ==========================================
// 1. MAIN MODULAR TIMELINE SHEET
// ==========================================
struct CreateJourneySheet: View {
    @Environment(\.dismiss) private var dismiss
    
    // Form State (Maps to Journey Prisma Model)
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
    
    // Cover Photo Picker States
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var coverImage: NSImage? = nil
    
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
                
                Text(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "New Timeline" : title)
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
                    
                    // SECTION 1: MINIMALIST COVER MEDIA
                    VStack(alignment: .leading, spacing: 12) {
                        FormSectionHeader(text: "Visual Accent")
                        
                        CustomFormRow(label: "Cover Photo") {
                            HStack(spacing: 12) {
                                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "photo.on.rectangle.angled")
                                        Text(coverImage == nil ? "Upload Custom Photo" : "Change Photo")
                                    }
                                    .font(AppTheme.subtitle)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(AppTheme.roseGoldDark)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                }
                                .buttonStyle(.plain)
                                .onChange(of: selectedItem) { _, newItem in
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
                                        self.selectedItem = nil
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
                    
                    // SECTION 2: GENERAL METADATA
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
                    
                    // SECTION 3: TIMELINE TIMESTAMPS
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
                    
                    // SECTION 4: COLLABORATORS
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
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            
            Divider()
                .opacity(0.2)
            
            // BOTTOM ACTION DRAWER
            HStack(spacing: 12) {
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .keyboardShortcut(.cancelAction)
                
                Button("Create") {
                    saveJourney()
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
        .frame(width: 460, height: 560)
        .background(AppTheme.primaryBackground)
        .preferredColorScheme(.light)
    }
    
    private func saveJourney() {
        dismiss()
    }
}

// ==========================================
// 2. SUPPORTING SUBVIEWS & UTILITIES
// ==========================================

struct CustomDatePickerRow: View {
    @Binding var day: Int?
    @Binding var month: Int?
    @Binding var year: Int?
    
    var body: some View {
        HStack(spacing: 8) {
            Picker("Year", selection: Binding(
                get: { year ?? 2026 },
                set: { year = $0 }
            )) {
                ForEach(1900...2100, id: \.self) { y in
                    Text(String(y)).tag(y)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .fixedSize()
            
            Picker("Month", selection: Binding(
                get: { month ?? 1 },
                set: { month = $0 }
            )) {
                ForEach(1...12, id: \.self) { m in
                    Text(Calendar.current.shortMonthSymbols[m - 1]).tag(m)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .fixedSize()
            
            Picker("Day", selection: Binding(
                get: { day ?? 1 },
                set: { day = $0 }
            )) {
                ForEach(1...31, id: \.self) { d in
                    Text(String(format: "%02d", d)).tag(d)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .fixedSize()
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat
    
    init(spacing: CGFloat = 6) {
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = handleLayout(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = handleLayout(proposal: proposal, subviews: subviews)
        for (index, coordinate) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + coordinate.x, y: bounds.minY + coordinate.y), proposal: .unspecified)
        }
    }
    
    private func handleLayout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var highestInRow: CGFloat = 0
        var positions: [CGPoint] = []
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += highestInRow + spacing
                highestInRow = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            highestInRow = max(highestInRow, size.height)
            currentX += size.width + spacing
        }
        
        let totalHeight = currentY + highestInRow
        let totalWidth = proposal.width ?? currentX
        return (CGSize(width: totalWidth, height: totalHeight), positions)
    }
}

#Preview {
    CreateJourneySheet()
}
