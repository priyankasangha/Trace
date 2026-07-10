import SwiftUI

// ==========================================
// REUSABLE BRAND ACCENTS
// ==========================================

struct SkinnyDivider: View {
    var body: some View {
        Rectangle()
            .fill(AppTheme.roseGoldDark.opacity(0.3))
            .frame(height: AppTheme.thinLineWidth)
    }
}

struct FineDotAccent: View {
    var body: some View {
        Circle()
            .fill(AppTheme.roseGoldBase)
            .frame(width: 4, height: 4)
            .padding(.horizontal, 6)
    }
}

struct FineLineBorder: ViewModifier {
    var color: Color = AppTheme.roseGoldLight.opacity(0.5)
    var cornerRadius: CGFloat = 12
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(color, lineWidth: AppTheme.thinLineWidth)
            )
    }
}

extension View {
    func fineLineBorder(color: Color = AppTheme.roseGoldLight.opacity(0.5), cornerRadius: CGFloat = 12) -> some View {
        self.modifier(FineLineBorder(color: color, cornerRadius: cornerRadius))
    }
}
