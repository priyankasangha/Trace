import SwiftUI
import PhotosUI
import AppKit

// ==========================================
// REUSABLE FORM DESIGN SYSTEM UTILITIES
// ==========================================

struct FormSectionHeader: View {
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(text.localizedCapitalized)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppTheme.roseGoldDark)
                .padding(.top, 4)
            
            Rectangle()
                .fill(AppTheme.roseGoldBase.opacity(0.4))
                .frame(width: 24, height: 1.5)
        }
    }
}

// ==========================================
// VIEW EXTENSIONS & SHAPE MODIFIERS
// ==========================================

extension View {
    func formFieldBorder() -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(AppTheme.roseGoldBase.opacity(0.2), lineWidth: 1)
        )
    }
}


// ==========================================
// TRACE SYSTEM: SHARED FORM LAYOUT ARCHITECTURE
// ==========================================

struct CustomFormRow<Content: View>: View {
    var label: String
    var labelWidth: CGFloat
    var content: Content
    
    init(label: String, labelWidth: CGFloat = 100, @ViewBuilder content: () -> Content) {
        self.label = label
        self.labelWidth = labelWidth
        self.content = content()
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text(label)
                .font(AppTheme.subtitle)
                .foregroundColor(AppTheme.primaryText.opacity(AppTheme.accentOpacity))
                .frame(width: labelWidth, alignment: .leading)
            
            content
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
    }
}

// ==========================================
// SHARED VIEW MODIFIERS & STYLES
// ==========================================

extension View {
    func styledInput() -> some View {
        self
            .textFieldStyle(.plain)
            .font(AppTheme.body)
            .foregroundColor(AppTheme.primaryText)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(AppTheme.primaryText.opacity(0.08), lineWidth: AppTheme.thinLineWidth)
            )
    }
}

// ==========================================
// APPKIT INTEGRATION: NATIVE SEARCH FIELD
// ==========================================

/// Whether NativeSearchField draws its own native bezel/background/icons,
/// or renders as a bare text field so a SwiftUI-drawn container (like a
/// custom capsule) is the only visible chrome.
enum SearchFieldChrome {
    case native // system bezel, background, and built-in search/cancel icons — default, unchanged behavior
    case plain  // no bezel, no background, no focus ring, no built-in icons — caller supplies its own chrome
}

/// A lightweight wrapper around the native macOS NSSearchField for quick filtering.
struct NativeSearchField: NSViewRepresentable {
    @Binding var text: String
    var placeholder: String = ""
    var chrome: SearchFieldChrome = .native
    var autoFocus: Bool = false
    var onCommit: () -> Void
    var onFocusLost: (() -> Void)? = nil
    
    func makeNSView(context: Context) -> NSSearchField {
        let searchField = NSSearchField()
        searchField.placeholderString = placeholder
        searchField.delegate = context.coordinator
        searchField.font = .systemFont(ofSize: 12)
        
        searchField.target = context.coordinator
        searchField.action = #selector(Coordinator.textCommitted)
        
        if chrome == .plain {
            searchField.isBezeled = false
            searchField.drawsBackground = false
            searchField.focusRingType = .none
            if let cell = searchField.cell as? NSSearchFieldCell {
                cell.searchButtonCell = nil
                cell.cancelButtonCell = nil
            }
        }
        
        if autoFocus {
            DispatchQueue.main.async {
                searchField.window?.makeFirstResponder(searchField)
            }
        }
        
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
        
        func controlTextDidEndEditing(_ obj: Notification) {
            parent.onFocusLost?()
        }
    }
}
// ==========================================
// SHARED SHEET CONTAINER
// ==========================================

struct SheetContainer<Content: View>: View {
    let title: String
    let primaryLabel: String
    let isPrimaryDisabled: Bool
    var onDismiss: () -> Void
    var onPrimary: () -> Void
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button(action: onDismiss) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.roseGoldDark)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                Text(title)
                    .font(AppTheme.title)
                    .foregroundColor(AppTheme.roseGoldDark)
                    .lineLimit(1)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 24)
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 26) {
                    content()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            
            Divider()
                .opacity(0.2)
            
            HStack(spacing: 12) {
                Spacer()
                
                Button("Cancel") { onDismiss() }
                    .buttonStyle(.bordered)
                    .keyboardShortcut(.cancelAction)
                
                Button(primaryLabel) { onPrimary() }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.roseGoldDark)
                    .keyboardShortcut(.defaultAction)
                    .disabled(isPrimaryDisabled)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(AppTheme.primaryBackground)
        }
        .background(AppTheme.primaryBackground)
    }
}

// ==========================================
// NSIMAGE ↔ BASE64 HELPERS
// ==========================================

extension NSImage {
    /// Compress to JPEG and return a base64-encoded string.
    func toBase64(compressionFactor: CGFloat = 0.7) -> String? {
        guard let tiff = tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let jpeg = rep.representation(using: .jpeg, properties: [.compressionFactor: compressionFactor])
        else { return nil }
        return jpeg.base64EncodedString()
    }
    
    /// Create an NSImage from a base64-encoded string.
    static func fromBase64(_ string: String) -> NSImage? {
        guard let data = Data(base64Encoded: string) else { return nil }
        return NSImage(data: data)
    }
}

// ==========================================
// SHARED COVER IMAGE PICKER
// ==========================================

struct CoverImagePicker: View {
    @Binding var selectedItem: PhotosPickerItem?
    @Binding var coverImage: NSImage?
    var onImagePicked: ((NSImage) -> Void)? = nil
    
    var body: some View {
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
                            if let handler = onImagePicked {
                                handler(nsImage)
                            } else {
                                coverImage = nsImage
                            }
                        }
                    }
                }
            }
            
            if let img = coverImage {
                Image(nsImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(AppTheme.primaryText.opacity(0.08), lineWidth: AppTheme.thinLineWidth)
                    )
                
                Button(action: { coverImage = nil; selectedItem = nil }) {
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

// ==========================================
// SHARED DATE PICKER ROW
// ==========================================

struct CustomDatePickerRow: View {
    @Binding var day: Int?
    @Binding var month: Int?
    @Binding var year: Int?
    
    var body: some View {
        HStack(spacing: 8) {
            Picker("Year", selection: Binding(get: { year ?? 2026 }, set: { year = $0 })) {
                ForEach(1900...2100, id: \.self) { y in
                    Text(String(y)).tag(y)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .fixedSize()
            
            Picker("Month", selection: Binding(get: { month ?? 1 }, set: { month = $0 })) {
                ForEach(1...12, id: \.self) { m in
                    Text(Calendar.current.shortMonthSymbols[m - 1]).tag(m)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .fixedSize()
            
            Picker("Day", selection: Binding(get: { day ?? 1 }, set: { day = $0 })) {
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

// ==========================================
// SHARED FLOW LAYOUT
// ==========================================

struct FlowLayout: Layout {
    var spacing: CGFloat
    
    init(spacing: CGFloat = 6) { self.spacing = spacing }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        handleLayout(proposal: proposal, subviews: subviews).size
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
        return (CGSize(width: proposal.width ?? currentX, height: currentY + highestInRow), positions)
    }
}

