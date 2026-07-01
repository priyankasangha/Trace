import SwiftUI

// ==========================================
// EDITORIAL JOURNEY DISPLAY CARD
//
// Interaction model, deliberately different from EventRow's double-tap:
// Events had no competing single-click action, so double-tap was free to
// use for revealing edit/delete. Journeys DO have a competing single-click
// action (opening the journey), so edit/delete are revealed on hover
// instead — two separate input channels, no ambiguity. Reuses the
// isHovered state this card already tracked for its scale/shadow effect.
// ==========================================
struct JourneyCardView: View {
    let journey: JourneyItem
    var onOpen: () -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                if let _ = journey.coverImageName {
                    Color.gray
                } else {
                    LinearGradient(
                        colors: [AppTheme.roseGoldLight.opacity(0.6), AppTheme.roseGoldBase.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                
                if journey.isOngoing {
                    Text("Ongoing")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(AppTheme.roseGoldDark)
                        .clipShape(Capsule())
                        .padding(10)
                        // Nudge the "Ongoing" pill out of the way when the
                        // edit/delete buttons are showing in the same corner.
                        .offset(y: isHovered ? 28 : 0)
                        .animation(.easeOut(duration: 0.15), value: isHovered)
                }
                
                EditDeleteButtons(onEdit: onEdit, onDelete: onDelete)
                    .padding(10)
                    .opacity(isHovered ? 1 : 0)
                    .scaleEffect(isHovered ? 1 : 0.85, anchor: .topTrailing)
                    .allowsHitTesting(isHovered)
                    .animation(.easeOut(duration: 0.15), value: isHovered)
            }
            .frame(height: 115)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(journey.title)
                    .font(AppTheme.title)
                    .foregroundColor(AppTheme.primaryText)
                    .lineLimit(1)
                
                Text(journey.description)
                    .font(AppTheme.body)
                    .foregroundColor(AppTheme.primaryText.opacity(0.7))
                    .lineLimit(2)
                    .frame(height: 34, alignment: .top)
                
                SkinnyDivider()
                    .padding(.vertical, 4)
                
                HStack {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(AppTheme.roseGoldDark.opacity(0.7))
                            .frame(width: 5, height: 5)
                        
                        Text(journey.dateRangeString)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(AppTheme.primaryText.opacity(AppTheme.accentOpacity))
                    
                    Spacer()
                    
                    HStack(spacing: 3) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 10))
                        Text("\(journey.collaboratorCount)")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(AppTheme.roseGoldDark)
                }
            }
            .padding(16)
            .background(Color(nsColor: .controlBackgroundColor))
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .fineLineBorder()
        .scaleEffect(isHovered ? 1.015 : 1.0)
        .shadow(color: Color.black.opacity(isHovered ? 0.04 : 0.0), radius: 8, x: 0, y: 4)
        .animation(.easeOut(duration: 0.2), value: isHovered)
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture(perform: onOpen)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
