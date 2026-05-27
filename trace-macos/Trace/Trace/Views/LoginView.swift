import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(AppState.self) private var appState
    
    var body: some View {
        ZStack {
            // 1. BACKGROUND: Your premium warm cream canvas
            AppTheme.primaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: 28) {
                Spacer()
                
                // BRANDING SECTION
                VStack(spacing: 16) {
                    // 2. APP ICON: Minimalist glowing ring design matching your new aesthetic
                    ZStack {
                        Circle()
                            .stroke(AppTheme.roseGoldBase, lineWidth: AppTheme.regularLineWidth)
                            .frame(width: 64, height: 64)
                            // Clean ambient shadow using your dark charcoal token at 8% opacity
                            .shadow(color: AppTheme.primaryText.opacity(0.08), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: "circle.circle") // Minimalist geometric icon
                            .font(.system(size: 24, weight: .light))
                            .foregroundColor(AppTheme.roseGoldDark)
                    }
                    
                    // 3. TYPOGRAPHY: Your signature cursive title + matched tagline
                    Text("Trace")
                        .font(AppTheme.decorativeFont(size: 34)) // Elegant cursive accent font
                        .foregroundColor(AppTheme.primaryText)   // Crisp charcoal contrast
                        .tracking(1.0)
                    
                    Text("TRACK YOUR DEVELOPMENT JOURNEYS")
                        .font(.system(size: 9, weight: .semibold, design: .monospaced)) // Clean fallback tracking text
                        .foregroundColor(AppTheme.primaryText.opacity(0.4))             // Softened charcoal
                        .tracking(2.0)
                }
                
                Spacer()
                
                // 4. SIGN IN WITH APPLE BUTTON
                SignInWithAppleButton(
                    onRequest: { request in request.requestedScopes = [.fullName, .email] },
                    onCompletion: { result in
                        if case .success = result {
                            DispatchQueue.main.async { appState.isLoggedIn = true }
                        }
                    }
                )
                // Swapped to dark button style for a dramatic stark contrast against the cream background
                .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                .frame(width: 260, height: 42)
                // A very soft ambient drop shadow so the button seats cleanly on the layout
                .shadow(color: AppTheme.primaryText.opacity(0.12), radius: 10, x: 0, y: 4)
                
                Spacer()
            }
            .padding(40)
        }
        .frame(width: 480, height: 360)
    }
}

#Preview {
    LoginView()
        .environment(AppState())
}
