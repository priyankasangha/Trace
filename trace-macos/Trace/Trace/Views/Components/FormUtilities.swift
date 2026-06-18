import SwiftUI

// ==========================================
// REUSABLE FORM DESIGN SYSTEM UTILITIES
// ==========================================

struct FormSectionHeader: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .tracking(1.2)
            .foregroundColor(AppTheme.roseGoldDark)
            .padding(.top, 4)
    }
}

struct FormRow<Content: View>: View {
    let label: String
    let labelWidth: CGFloat
    let content: Content
    
    init(label: String, labelWidth: CGFloat, @ViewBuilder content: () -> Content) {
        self.label = label
        self.labelWidth = labelWidth
        self.content = content()
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.primaryText.opacity(0.7))
                .frame(width: labelWidth, alignment: .leading)
            
            content
                .frame(maxWidth: .infinity, alignment: .leading)
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

// ==========================================
// APPKIT INTEGRATION: NATIVE SEARCH FIELD
// ==========================================

/// A lightweight wrapper around the native macOS NSSearchField for quick filtering.
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
