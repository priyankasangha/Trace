import SwiftUI

struct TimelineEventCard: View {
    let category: String
    let title: String
    let dateString: String
    let description: String
    
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(category)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(AppTheme.roseGoldDark)
                    .tracking(1.5)
                
                Spacer()
                
                Text(dateString)
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .foregroundColor(AppTheme.primaryText.opacity(0.4))
            }
            
      //      Divider().opacity(0.5)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppTheme.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.primaryText.opacity(0.6))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(18)
        .background(AppTheme.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.roseGoldLight.opacity(0.25), lineWidth: 1)
        )
        .shadow(
            color: Color.black.opacity(isHovered ? AppTheme.cardShadowOpacityHovered : AppTheme.cardShadowOpacityResting),
            radius: AppTheme.cardShadowRadius,
            x: 0,
            y: AppTheme.cardShadowY
        )
        .scaleEffect(isHovered ? 1.01 : 1.0)
        .animation(.easeOut(duration: 0.2), value: isHovered)
        .onHover { isHovered = $0 }
        .frame(width: 280)
    }
}

#Preview {
    TimelineEventCard(category: "test", title: "test", dateString: "ygb", description: "test")
}
