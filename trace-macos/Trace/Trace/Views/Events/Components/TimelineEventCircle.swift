import SwiftUI

struct TimelineEventCircle: View {
    let imageName: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(AppTheme.roseGoldDark.opacity(0.08))
            
            Image(systemName: imageName)
                .font(.system(size: 46))
                .foregroundColor(AppTheme.roseGoldDark.opacity(0.8))
        }
        .frame(width: 200, height: 200)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(AppTheme.roseGoldLight.opacity(0.35), lineWidth: 1.5)
        )
    }
}
