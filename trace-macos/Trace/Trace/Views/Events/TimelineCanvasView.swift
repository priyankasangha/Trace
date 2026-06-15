import SwiftUI
import AppKit

// =========================================================================
// 1. GLOBAL APP THEME CORES
// =========================================================================
struct AppThemes {
    static let cardBackground = Color.white.opacity(0.65) // Translucent dashboard card backing
}

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
// 2. ATTACHED DATA STRUCTURE STUB
// =========================================================================
struct TimelineEventStub: Identifiable {
    let id = UUID()
    let category: String
    let title: String
    let dateString: String
    let description: String
    let imageName: String
}

// =========================================================================
// 3. BOUNDED SIDE ALIGNMENT ROW
// =========================================================================
struct BoundedVerticalMilestoneRow: View {
    let event: TimelineEventStub
    let isLeftAligned: Bool
    
    private let contentBlockWidth: CGFloat = 280
    private let horizontalLineLength: CGFloat = 100
    
    var body: some View {
        HStack(spacing: 0) {
            
            // COLUMN 1: LEFT WING AREA
            HStack(spacing: 0) {
                if isLeftAligned {
                    Spacer()
                    EventBlock(event: event)
                    
                    Rectangle()
                        .fill(AppTheme.roseGoldLight.opacity(0.3))
                        .frame(width: horizontalLineLength, height: 1.5)
                        .offset(y: -106)
                } else {
                    Spacer()
                }
            }
            .frame(width: contentBlockWidth + horizontalLineLength)
            
            // COLUMN 2: CENTER SPINE ANCHOR NODE
            Color.clear
                .frame(width: 2)
            
            // COLUMN 3: RIGHT WING AREA
            HStack(spacing: 0) {
                if !isLeftAligned {
                    Rectangle()
                        .fill(AppTheme.roseGoldLight.opacity(0.3))
                        .frame(width: horizontalLineLength, height: 1.5)
                        .offset(y: -106)
                    
                    EventBlock(event: event)
                    Spacer()
                } else {
                    Spacer()
                }
            }
            .frame(width: contentBlockWidth + horizontalLineLength)
        }
        .frame(maxWidth: .infinity)
    }
}

// =========================================================================
// 4. TIMELINE CANVAS VIEW WITH HIGH-AESTHETIC HERO ARENA
// =========================================================================
struct TimelineCanvasView: View {
    let journeyTitle: String
    let journeyDescription: String
    
    @State private var sampleEvents: [TimelineEventStub] = [
        TimelineEventStub(
            category: "ARCHITECTURE",
            title: "Project Conception Blueprint",
            dateString: "MAY 01, 2026",
            description: "Initial outline of architecture layers written down on paper.",
            imageName: "doc.text.image"
        ),
        TimelineEventStub(
            category: "DATABASE",
            title: "Database Schema Finalized",
            dateString: "MAY 31, 2026",
            description: "Mapped out all core models and attributes natively in Prisma.",
            imageName: "externaldrive.badge.checkmark"
        ),
        TimelineEventStub(
            category: "INTERFACE",
            title: "First Fluid UI Prototype",
            dateString: "JUN 12, 2026",
            description: "Successfully rendered fluid macOS windows and basic sheets.",
            imageName: "window.shade.closed"
        )
    ]
    
    private var initials: String {
        let words = journeyTitle.components(separatedBy: .whitespacesAndNewlines)
        let cleanWords = words.filter { !$0.isEmpty }
        if cleanWords.count >= 2 {
            return String((cleanWords[0].first ?? " ").uppercased() + (cleanWords[1].first ?? " ").uppercased())
        } else {
            return String(journeyTitle.prefix(2)).uppercased()
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // =================================================================
            // IMMERSIVE HERO IDENTITY HEADER
            // =================================================================
            VStack(alignment: .leading, spacing: 28) {
                
                HStack(alignment: .top, spacing: 32) {
                    
                    // CINEMATIC MONOGRAM IDENTITY BADGE
                    ZStack {
                        Circle()
                            .fill(AppTheme.roseGoldDark.opacity(0.08))
                        
                        Text(initials)
                            .font(.system(size: 32, weight: .light, design: .serif))
                            .foregroundColor(AppTheme.roseGoldDark)
                            .tracking(1)
                    }
                    .frame(width: 84, height: 84)
                    .overlay(
                        Circle()
                            .stroke(AppTheme.roseGoldLight.opacity(0.3), lineWidth: 1)
                    )
                    
                    // EXPANDED BRANDING TYPOGRAPHY ENGINE
                    VStack(alignment: .leading, spacing: 10) {
                        
                        // Editorial Context Label
                        Text("ACTIVE CONTEXT TIMELINE")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(AppTheme.roseGoldDark)
                            .tracking(3.5)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(journeyTitle)
                                .font(.system(size: 56, weight: .bold, design: .serif))
                                .foregroundColor(AppTheme.roseGoldDark)
                                .shadow(color: AppTheme.roseGoldDark.opacity(0.05), radius: 2, x: 0, y: 2)
                            
                            if !journeyDescription.isEmpty {
                                Text(journeyDescription)
                                    .font(.system(size: 15, weight: .medium, design: .serif))
                                    .italic()
                                    .foregroundColor(AppTheme.primaryText.opacity(0.55))
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // HEADER ACTION COMPONENT
                    Button(action: {}) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                            Text("NEW MILESTONE")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .tracking(1)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(AppTheme.roseGoldDark)
                        .cornerRadius(24)
                        .shadow(color: AppTheme.roseGoldDark.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                }
                
                // DATA STRUCTURAL LINE MATRIX
                HStack(spacing: 24) {
                    HStack(spacing: 6) {
                        Circle().fill(AppTheme.roseGoldDark).frame(width: 6, height: 6)
                        Text("\(sampleEvents.count) TOTAL TRACKED ENGINES")
                    }
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(AppTheme.roseGoldDark)
                    .tracking(1)
                    
                    Rectangle()
                        .fill(AppTheme.roseGoldLight.opacity(0.25))
                        .frame(width: 1, height: 14)
                    
                    Text("ENGINEERING CANVAS METADATA PLATFORM")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.primaryText.opacity(0.35))
                        .tracking(2)
                    
                    Spacer()
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 64)
            .padding(.vertical, 48)
            .background(
                AppThemes.cardBackground
                    .ignoresSafeArea()
            )
            .overlay(
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(AppTheme.roseGoldLight.opacity(0.2))
                        .frame(height: 1)
                }
            )
            
            // TIMELINE CANVAS STREAM
            ScrollView(.vertical, showsIndicators: true) {
                ZStack(alignment: .top) {
                    
                    // Central Axis Tracking Spine
                    Rectangle()
                        .fill(AppTheme.roseGoldLight.opacity(0.3))
                        .frame(width: 2)
                        .padding(.vertical, 60)
                    
                    VStack(spacing: 110) {
                        ForEach(Array(sampleEvents.enumerated()), id: \.offset) { index, event in
                            let isLeftAligned = index % 2 == 0
                            BoundedVerticalMilestoneRow(event: event, isLeftAligned: isLeftAligned)
                        }
                    }
                    .padding(.vertical, 60)
                }
                .frame(maxWidth: .infinity)
            }
            .background(AppTheme.primaryBackground.opacity(0.98))
        }
    }
}

// =========================================================================
// 5. CANVAS RENDERING PREVIEW WINDOW
// =========================================================================
#Preview {
    TimelineCanvasView(
        journeyTitle: "Trace Architecture",
        journeyDescription: "By Priyanka, For Shrey — An immersive canvas mapping core architectural sprints."
    )
    .frame(width: 1400, height: 950)
}
