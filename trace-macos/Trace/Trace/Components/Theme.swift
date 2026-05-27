import SwiftUI

// ==========================================
// 1. THEME DESIGN TOKENS
// ==========================================
struct AppTheme {
    // Backgrounds
    static let primaryBackground = Color(hex: "#F3EFE9") // Soft cream
    
    // Core Typography & Fine Lines
    static let primaryText = Color(hex: "#2A3038")       // Dark blue-toned charcoal
    
    // Rose Gold Palette Hierarchy
    static let roseGoldLight = Color(hex: "#F3D1C4")     // Subtle accents / canvas fills
    static let roseGoldBase = Color(hex: "#E8BAB2")      // Primary actions / buttons
    static let roseGoldMedium = Color(hex: "#E0A996")    // Hover & active states
    static let roseGoldDark = Color(hex: "#C68B75")      // Fine-line borders and icons
    
    // Layout Constants
    static let thinLineWidth: CGFloat = 1.0
    static let regularLineWidth: CGFloat = 1.5
    
    // Custom Cursive Dynamic Font
    static func decorativeFont(size: CGFloat) -> Font {
        return Font.custom("YourCursiveFontName", size: size)
    }
}

// ==========================================
// 2. HELPER EXTENSIONS (Hex Support)
// ==========================================
extension Color {
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
            (a, r, g, b) = (1, 1, 1, 1)
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
