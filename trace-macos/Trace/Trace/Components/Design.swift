import SwiftUI

// ==========================================
// REUSABLE BRAND ACCENTS
// ==========================================

/// A ultra-thin, elegant rose gold divider line for separating editorial layout content.
struct SkinnyDivider: View {
    var body: some View {
        Rectangle()
            .fill(AppTheme.roseGoldDark.opacity(0.3)) // Softened for that fine-line look
            .frame(height: AppTheme.thinLineWidth)    // Uses your 1.0pt token
    }
}

/// A delicate, minimalist decorative dot accent used to center-anchor sections or split text inline.
struct FineDotAccent: View {
    var body: some View {
        Circle()
            .fill(AppTheme.roseGoldBase)
            .frame(width: 4, height: 4)
            .padding(.horizontal, 6)
    }
}

/// A premium frame modifier that adds an ultra-fine rose gold border around any layout card or container.
struct FineLineBorder: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.roseGoldLight.opacity(0.5), lineWidth: AppTheme.thinLineWidth)
            )
    }
}

// Helper extension to make the border modifier incredibly clean to call on any View
extension View {
    func fineLineBorder() -> some View {
        self.modifier(FineLineBorder())
    }
}
