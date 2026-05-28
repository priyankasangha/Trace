import SwiftUI

// ==========================================
// 1. THEME DESIGN TOKENS
// ==========================================
struct AppTheme {
    // ------------------------------------------
    // A. COLORS
    // ------------------------------------------
    static let primaryBackground = Color(hex: "#F3EFE9") // light cream
    static let primaryText = Color(hex: "#2A3038")       // Dark blue-toned charcoal
    
    // Rose Gold Palette
    static let roseGoldLight = Color(hex: "#F3D1C4")
    static let roseGoldBase = Color(hex: "#E8BAB2")
    static let roseGoldMedium = Color(hex: "#E0A996")
    static let roseGoldDark = Color(hex: "#C68B75")
    
    // ------------------------------------------
    // B. LAYOUT CONSTANTS
    // ------------------------------------------
    static let thinLineWidth: CGFloat = 1.0
    static let regularLineWidth: CGFloat = 1.5
    
    // ------------------------------------------
    // C. TYPOGRAPHY SYSTEM (Semantic Roles)
    // ------------------------------------------
    
    static let appNameText: Font = .system(size: 34, weight: .regular, design: .serif).italic()
    
    static let largeTitle: Font = .system(size: 28, weight: .bold, design: .default)
    
    static let title: Font = .system(size: 20, weight: .semibold, design: .default)
    
    static let body: Font = .system(size: 14, weight: .regular, design: .default)
    
    static let subtitle: Font = .system(size: 12, weight: .medium, design: .default)
    
    static let tinyText: Font = .system(size: 6, weight: .regular, design: .default).italic()
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
