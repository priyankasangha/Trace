import SwiftUI

// ==========================================
// 1. THEME DESIGN TOKENS
// ==========================================
struct AppTheme {
    // ------------------------------------------
    // A. COLORS
    // ------------------------------------------
    
    // NATIVE MAC FIX: Uses the exact system canvas color used by first-party apps like Notes and Finder
    static let primaryBackground = Color.dynamic(
        light: Color(nsColor: .windowBackgroundColor),
        dark: Color(nsColor: .windowBackgroundColor)
    )
    
    static let blurViewBackground = Color(hex: "#F5F5F533")
    
    // Uses standard high-contrast system label colors that guarantee readability
    static let primaryText = Color.dynamic(
        light: Color(nsColor: .labelColor),
        dark: Color(nsColor: .labelColor)
    )
    
    // Rose Gold Palette
    static let roseGoldLight = Color(hex: "#F3D1C4")
    static let roseGoldBase  = Color(hex: "#E8BAB2")
    static let roseGoldMedium = Color(hex: "#E0A996")
    static let roseGoldDark   = Color(hex: "#C68B75")
    
    // ------------------------------------------
    // B. LAYOUT & GEOMETRY CONSTANTS
    // ------------------------------------------
    static let thinLineWidth: CGFloat = 1.0
    static let regularLineWidth: CGFloat = 1.5
    
    // Component dimensions to keep layouts crisp and unified
    static let authButtonWidth: CGFloat = 220
    static let authButtonHeight: CGFloat = 32
    static let windowTopSafetyPadding: CGFloat = 36
    
    // ------------------------------------------
    // C. TYPOGRAPHY SYSTEM (Semantic Roles)
    // ------------------------------------------
    static let appNameTitle: Font = .system(size: 52, weight: .light, design: .serif)
    static let appTagline: Font = .system(size: 11, weight: .regular)
    static let dedicationPlacard: Font = .system(size: 10, weight: .light, design: .serif).italic()
    
    static let largeTitle: Font = .system(size: 28, weight: .bold, design: .default)
    static let title: Font = .system(size: 20, weight: .semibold, design: .default)
    static let body: Font = .system(size: 14, weight: .regular, design: .default)
    static let subtitle: Font = .system(size: 12, weight: .medium, design: .default)
    static let tinyText: Font = .system(size: 6, weight: .regular, design: .default).italic()
    
    // ------------------------------------------
    // D. BRAND TEXT TRACKING (Letter Spacing)
    // ------------------------------------------
    static let titleTracking: CGFloat = 8.0
    static let taglineTracking: CGFloat = 5.0
    static let placardTracking: CGFloat = 1.0
    
    // ------------------------------------------
    // E. BRAND OPACITY TOKENS
    // ------------------------------------------
    static let accentOpacity: Double = 0.6
    static let mutedTextOpacity: Double = 0.8
}

// ==========================================
// 2. HELPER EXTENSIONS (Hex & Dynamic Support)
// ==========================================
extension Color {
    // 💡 THE COMPILER FIX: 'static' keyword lets you call Color.dynamic on the type safely
    static func dynamic(light: Color, dark: Color) -> Color {
        #if os(macOS)
        return Color(NSColor(name: nil) { appearance in
            if appearance.bestMatch(from: [.darkAqua, .vibrantDark]) != nil {
                return NSColor(dark)
            }
            return NSColor(light)
        })
        #else
        return Color(uiColor: UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
        #endif
    }

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 255, 255, 255)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
