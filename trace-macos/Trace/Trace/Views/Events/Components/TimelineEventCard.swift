import SwiftUI

struct TimelineEventCard: View {
    let category: String
    let title: String
    let dateString: String
    let description: String
    
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
            
            Divider().opacity(0.1)
            
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
        .background(AppThemes.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.roseGoldLight.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 4)
        .frame(width: 280)
    }
}

#Preview {
    TimelineEventCard(category: "test", title: "test", dateString: "test", description: "test")
}
