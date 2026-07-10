import SwiftUI

// =========================================================================
// BOUNDED SIDE ALIGNMENT ROW
// =========================================================================
struct BoundedVerticalEventRow: View {
    let event: TimelineEventStub
    let isLeftAligned: Bool
    let isFocused: Bool
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    private let contentBlockWidth: CGFloat = 280
    private let horizontalLineLength: CGFloat = 60
    
    var body: some View {
        HStack(spacing: 0) {
            // COLUMN 1: LEFT WING AREA
            HStack(spacing: 0) {
                if isLeftAligned {
                    Spacer()
                    renderInteractiveAssetStack()
                    
                    Rectangle()
                        .fill(AppTheme.roseGoldLight.opacity(0.3))
                        .frame(width: horizontalLineLength, height: 1.5)
                } else {
                    Spacer()
                }
            }
            .frame(width: contentBlockWidth + horizontalLineLength)
            
            // COLUMN 2: CENTER SPINE ANCHOR NODE
            Circle()
                .fill(AppTheme.roseGoldBase)
                .frame(width: 8, height: 8)
                .overlay(Circle().stroke(AppTheme.roseGoldLight.opacity(0.4), lineWidth: 2))
                .frame(width: 2)
            
            // COLUMN 3: RIGHT WING AREA
            HStack(spacing: 0) {
                if !isLeftAligned {
                    Rectangle()
                        .fill(AppTheme.roseGoldLight.opacity(0.3))
                        .frame(width: horizontalLineLength, height: 1.5)
                    
                    renderInteractiveAssetStack()
                    Spacer()
                } else {
                    Spacer()
                }
            }
            .frame(width: contentBlockWidth + horizontalLineLength)
        }
        .frame(maxWidth: .infinity)
    }
    
    // EventBlock (which wraps TimelineEventCircle + TimelineEventCard) owns
    // the icon rendering entirely. We only overlay the focus-triggered
    // edit/delete buttons on top of it here.
    @ViewBuilder
    private func renderInteractiveAssetStack() -> some View {
        VStack(spacing: 12) {
            EventBlock(event: event)
                .overlay(alignment: isLeftAligned ? .topLeading : .topTrailing) {
                    // TimelineEventCircle is 200pt wide, centered inside EventBlock's
                    // 280pt frame — a 40pt margin each side. Padding in from the frame
                    // edge before offsetting lines the buttons up with the circle's
                    // actual corner instead of EventBlock's outer edge.
                    EditDeleteButtons(onEdit: onEdit, onDelete: onDelete)
                        .padding(isLeftAligned ? .leading : .trailing, 40)
                        .offset(x: isLeftAligned ? -6 : 6, y: -6)
                        .opacity(isFocused ? 1 : 0)
                        .scaleEffect(isFocused ? 1 : 0.85, anchor: isLeftAligned ? .topLeading : .topTrailing)
                        .allowsHitTesting(isFocused)
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isFocused)
                }
        }
        .frame(width: contentBlockWidth)
    }
}

// =========================================================================
// ISOLATED EVENT ROW CONTAINER (Manages Interaction State Animations)
// =========================================================================
struct EventRowContainer: View {
    let event: TimelineEventStub
    let isLeftAligned: Bool
    let isFocused: Bool
    var onDoubleTap: () -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        BoundedVerticalEventRow(
            event: event,
            isLeftAligned: isLeftAligned,
            isFocused: isFocused,
            onEdit: onEdit,
            onDelete: onDelete
        )
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .scaleEffect(isFocused ? 1.04 : 1.0)
        .shadow(color: isFocused ? Color.black.opacity(0.12) : Color.clear, radius: 16, x: 0, y: 10)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isFocused)
        .onTapGesture(count: 2, perform: onDoubleTap)
    }
}
