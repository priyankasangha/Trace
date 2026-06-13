import SwiftUI
import AppKit

// =========================================================================
// 1. GLOBAL APP THEME CORES
// =========================================================================

// Extension to cleanly parse your premium hex strings natively on macOS
extension NSColor {
    convenience init?(hex: String) {
        let r, g, b: CGFloat
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255
                    self.init(red: r, green: g, blue: b, alpha: 1.0)
                    return
                }
            }
        }
        return nil
    }
}

// =========================================================================
// 2. MAIN VERTICAL TIMELINE CANVAS VIEW
// =========================================================================
struct TimelineCanvasView: View {
    let journeyTitle: String
    let journeyDescription: String
    
    // Core Array utilizing the backend model structure below
    @State private var sampleEvents: [TimelineEventStub] = [
        TimelineEventStub(
            title: "Project Conception Blueprint",
            dateString: "MAY 01, 2026",
            description: "Initial outline of architecture layers written down on paper.",
            imageName: "doc.text.image"
        ),
        TimelineEventStub(
            title: "Database Schema Finalized",
            dateString: "MAY 31, 2026",
            description: "Mapped out all core models and attributes natively in Prisma.",
            imageName: "externaldrive.badge.checkmark"
        ),
        TimelineEventStub(
            title: "First Fluid UI Prototype",
            dateString: "JUN 12, 2026",
            description: "Successfully rendered fluid macOS windows and basic sheets.",
            imageName: "window.shade.closed"
        )
    ]
    
    @State private var isPresentingCreateEvent: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            // NATIVE MAC APP BAR HEADER
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(journeyTitle)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.roseGoldDark)
                    
                    if !journeyDescription.isEmpty {
                        Text(journeyDescription)
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.primaryText.opacity(0.6))
                    }
                }
                
                Spacer()
                
                Button(action: { isPresentingCreateEvent = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(AppTheme.roseGoldDark)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .help("Add New Event Milestone")
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 20)
            .background(AppTheme.primaryBackground)
            
            Divider().opacity(0.15)
            
            // SCROLLABLE TIMELINE STREAM
            ScrollView(.vertical, showsIndicators: true) {
                ZStack(alignment: .top) {
                    
                    // Central Tracking Axis Line
                    Rectangle()
                        .fill(AppTheme.roseGoldLight.opacity(0.4))
                        .frame(width: 2)
                        .padding(.vertical, 40)
                    
                    // Iterative Content Rows
                    VStack(spacing: 56) {
                        ForEach(Array(sampleEvents.enumerated()), id: \.offset) { index, event in
                            let isLeftAligned = index % 2 == 0
                            VerticalMilestoneRow(event: event, isLeftAligned: isLeftAligned)
                        }
                    }
                    .padding(.vertical, 40)
                }
                .frame(maxWidth: .infinity)
            }
            .background(AppTheme.primaryBackground.opacity(0.98))
        }
    }
}

// =========================================================================
// 3. ALTERNATING MILESTONE STRUCTURAL ROW
// =========================================================================
struct VerticalMilestoneRow: View {
    let event: TimelineEventStub
    let isLeftAligned: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            if isLeftAligned {
                // Content Left | Center Spine | Balanced Empty Spacer Right
                MilestoneBlock(event: event, isLeftAligned: true)
                Spacer().frame(width: 240)
                
            } else {
                // Balanced Empty Spacer Left | Center Spine | Content Right
                Spacer().frame(width: 240)
                MilestoneBlock(event: event, isLeftAligned: false)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// =========================================================================
// 4. MILESTONE BLOCK (CIRCLE PHOTOGRAPHY + CAPTIONS)
// =========================================================================
struct MilestoneBlock: View {
    let event: TimelineEventStub
    let isLeftAligned: Bool
    
    // Exact geometric math calculation bridging center of circle to center spine
    private let lineLength: CGFloat = 120
    
    var body: some View {
        VStack(alignment: .center, spacing: 14) {
            
            // PHOTO IMAGE FRAME
            ZStack {
                Circle()
                    .fill(AppTheme.roseGoldLight.opacity(0.15))
                
                Image(systemName: event.imageName)
                    .font(.system(size: 32))
                    .foregroundColor(AppTheme.roseGoldDark.opacity(0.7))
            }
            .frame(width: 140, height: 140)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(AppTheme.roseGoldLight.opacity(0.5), lineWidth: 1)
            )
            // THE UNDERLAYING ANCHOR LINE CODES
            .background(
                GeometryReader { geo in
                    Rectangle()
                        .fill(AppTheme.roseGoldLight.opacity(0.4))
                        .frame(width: lineLength, height: 1.5)
                        .position(
                            x: isLeftAligned ? geo.size.width / 2 + lineLength / 2 : geo.size.width / 2 - lineLength / 2,
                            y: geo.size.height / 2
                        )
                }
            )
            
            // METADATA LABELS (Sits safely below circle, completely unbothered by line math)
            VStack(alignment: .center, spacing: 4) {
                Text(event.dateString)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(AppTheme.roseGoldDark)
                
                Text(event.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.center)
                
                Text(event.description)
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.primaryText.opacity(0.55))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: 200)
        }
        .frame(width: 240)
    }
}

// =========================================================================
// 5. NATIVE BACKEND MODEL COMPATIBILITY STUB
// =========================================================================
struct TimelineEventStub: Identifiable {
    let id = UUID()
    let title: String
    let dateString: String
    let description: String
    let imageName: String
}

// =========================================================================
// 6. CANVAS RENDERING PREVIEW WINDOW
// =========================================================================
#Preview {
    TimelineCanvasView(
        journeyTitle: "Trace Engineering Canvas",
        journeyDescription: "By Priyanka, For Shrey"
    )
    .frame(width: 700, height: 650)
}
