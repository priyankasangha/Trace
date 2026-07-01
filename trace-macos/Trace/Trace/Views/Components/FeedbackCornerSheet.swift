import SwiftUI

struct FeedbackCornerSheet: View {
    var onDismiss: () -> Void
    
    @State private var feedbackText: String = ""
    @State private var selectedPriority: Int = 3
    
    var body: some View {
        SheetContainer(
            title: "Shrey's Feedback Corner",
            primaryLabel: "Submit",
            isPrimaryDisabled: feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            onDismiss: onDismiss,
            onPrimary: {
                // TODO: wire up to backend
                onDismiss()
            }
        ) {
            VStack(alignment: .leading, spacing: 12) {
                FormSectionHeader(text: "PRIORITY")
                
                CustomFormRow(label: "Level") {
                    HStack(spacing: 10) {
                        ForEach(1...5, id: \.self) { level in
                            Button(action: { selectedPriority = level }) {
                                Text("\(level)")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(selectedPriority == level ? .white : AppTheme.roseGoldDark)
                                    .frame(width: 30, height: 30)
                                    .background(
                                        Circle()
                                            .fill(selectedPriority == level ? AppTheme.roseGoldDark : AppTheme.roseGoldLight.opacity(0.3))
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(AppTheme.roseGoldDark.opacity(selectedPriority == level ? 0 : 0.4), lineWidth: AppTheme.thinLineWidth)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                        
                        Spacer()
                    }
                }
                
                HStack {
                    Text("1 = Low")
                        .foregroundColor(AppTheme.primaryText.opacity(0.35))
                    Spacer()
                    Text("5 = Critical")
                        .foregroundColor(AppTheme.primaryText.opacity(0.35))
                }
                .font(.system(size: 10, weight: .medium))
                .padding(.leading, 116)
                .padding(.trailing, 24)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                FormSectionHeader(text: "FEEDBACK")
                
                CustomFormRow(label: "Notes") {
                    TextEditor(text: $feedbackText)
                        .font(AppTheme.body)
                        .foregroundColor(AppTheme.primaryText)
                        .scrollContentBackground(.hidden)
                        .padding(8)
                        .frame(minHeight: 160)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(AppTheme.primaryText.opacity(0.08), lineWidth: AppTheme.thinLineWidth)
                        )
                }
            }
        }
        .frame(width: 460, height: 440)
    }
}

struct FeedbackOverlayModifier: ViewModifier {
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture { isPresented = false }
                        
                        FeedbackCornerSheet(onDismiss: { isPresented = false })
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.25), radius: 20)
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: isPresented)
    }
}
