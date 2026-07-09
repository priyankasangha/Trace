import SwiftUI
import AppKit

struct TimelineEventCircle: View {
    let imageName: String
    var coverImageData: String? = nil
    
    var body: some View {
        ZStack {
            Circle()
                .fill(AppTheme.roseGoldDark.opacity(0.08))
            
            if let data = coverImageData, let nsImage = NSImage.fromBase64(data) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: imageName)
                    .font(.system(size: 46))
                    .foregroundColor(AppTheme.roseGoldDark.opacity(0.8))
            }
        }
        .frame(width: 200, height: 200)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(AppTheme.roseGoldLight.opacity(0.35), lineWidth: 1.5)
        )
    }
}
