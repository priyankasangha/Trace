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
    
    // Timeline Date Architecture (Optional Ints for Native Placeholders)
    @State private var startDay: Int? = 1
    @State private var startMonth: Int? = 1
    @State private var startYear: Int? = Calendar.current.component(.year, from: Date())
    
    @State private var endDay: Int? = 1
    @State private var endMonth: Int? = 1
    @State private var endYear: Int? = Calendar.current.component(.year, from: Date())
    
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
                
                // 💡 DYNAMIC HEADER TITLE UPDATE
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
                        Text("Visual Accent")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(AppTheme.placardTracking)
                            .foregroundColor(AppTheme.roseGoldDark)
                        
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
                        Text("GENERAL")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(AppTheme.placardTracking)
                            .foregroundColor(AppTheme.roseGoldDark)
                        
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
                        Text("DATES")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(AppTheme.placardTracking)
                            .foregroundColor(AppTheme.roseGoldDark)
                        
                        CustomFormRow(label: "Start Date") {
                            CustomDatePickerRow(day: $startDay, month: $startMonth, year: $startYear)
                        }
                        
                        CustomFormRow(label: "End Date") {
                            CustomDatePickerRow(day: $endDay, month: $endMonth, year: $endYear)
                                .disabled(isOngoing)
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
                                            endYear = Calendar.current.component(.year, from: Date())
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
                        Text("COLLABORATORS")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(AppTheme.placardTracking)
                            .foregroundColor(AppTheme.roseGoldDark)
                        
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
// 2. STYLED NATIVE DROPDOWN SELECTORS
// ==========================================
struct CustomDatePickerRow: View {
    @Binding var day: Int?
    @Binding var month: Int?
    @Binding var year: Int?
    
    private var yearRange: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((currentYear - 20)...(currentYear + 10))
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Picker("", selection: $day) {
                if day == nil { Text("DD").tag(Int?.none) }
                ForEach(1...31, id: \.self) { d in
                    Text(String(format: "%02d", d)).tag(Int?.some(d))
                }
            }
            .pickerStyle(.menu)
            .controlSize(.regular)
            .labelsHidden()
            .fixedSize()
            
            Picker("", selection: $month) {
                if month == nil { Text("MM").tag(Int?.none) }
                ForEach(1...12, id: \.self) { m in
                    Text(String(format: "%02d", m)).tag(Int?.some(m))
                }
            }
            .pickerStyle(.menu)
            .controlSize(.regular)
            .labelsHidden()
            .fixedSize()
            
            Picker("", selection: $year) {
                if year == nil { Text("YYYY").tag(Int?.none) }
                ForEach(yearRange, id: \.self) { y in
                    Text(String(y)).tag(Int?.some(y))
                }
            }
            .pickerStyle(.menu)
            .controlSize(.regular)
            .labelsHidden()
            .fixedSize()
            
            Spacer()
        }
    }
}

extension View {
    func styledInput() -> some View {
        self
            .textFieldStyle(.plain)
            .font(AppTheme.body)
            .foregroundColor(AppTheme.primaryText)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(AppTheme.primaryText.opacity(0.08), lineWidth: AppTheme.thinLineWidth)
            )
    }
}

struct CustomFormRow<Content: View>: View {
    var label: String
    var content: Content
    
    init(label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text(label)
                .font(AppTheme.subtitle)
                .foregroundColor(AppTheme.primaryText.opacity(AppTheme.accentOpacity))
                .frame(width: 100, alignment: .leading)
            
            content
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}

// ==========================================
// 3. APPKIT NATIVE NSSEARCHFIELD
// ==========================================
struct NativeSearchField: NSViewRepresentable {
    @Binding var text: String
    var placeholder: String = ""
    var onCommit: () -> Void
    
    func makeNSView(context: Context) -> NSSearchField {
        let searchField = NSSearchField()
        searchField.placeholderString = placeholder
        searchField.delegate = context.coordinator
        searchField.font = .systemFont(ofSize: 12)
        
        searchField.target = context.coordinator
        searchField.action = #selector(Coordinator.textCommitted)
        return searchField
    }
    
    func updateNSView(_ nsView: NSSearchField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSSearchFieldDelegate {
        var parent: NativeSearchField
        
        init(_ parent: NativeSearchField) {
            self.parent = parent
        }
        
        @objc func textCommitted() {
            parent.onCommit()
        }
        
        func controlTextDidChange(_ obj: Notification) {
            if let searchField = obj.object as? NSSearchField {
                parent.text = searchField.stringValue
            }
        }
    }
}

// ==========================================
// 4. FLOW LAYOUT CONFORMANCE
// ==========================================
struct FlowLayout: Layout {
    var spacing: CGFloat
    
    init(spacing: CGFloat = 6) {
        self.spacing = spacing
    }
    
    typealias Cache = ()
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        let width = proposal.width ?? 300
        var height: CGFloat = 0
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > width {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            rowHeight = max(rowHeight, size.height)
            currentX += size.width + spacing
        }
        height = currentY + rowHeight
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX {
                currentX = bounds.minX
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)
            rowHeight = max(rowHeight, size.height)
            currentX += size.width + spacing
        }
    }
}

#Preview {
    CreateJourneySheet()
}
