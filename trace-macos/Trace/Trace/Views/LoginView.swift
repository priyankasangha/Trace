import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(AppState.self) private var appState
    
    @State private var isAnimated = false
    @State private var heartScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            AppTheme.primaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: AppTheme.windowTopSafetyPadding)
                
                Spacer()
                
                VStack(spacing: 20) {
                    Text("Trace")
                        .font(AppTheme.appNameTitle)
                        .foregroundStyle(AppTheme.roseGoldDark)
                        .tracking(AppTheme.titleTracking)
                        .opacity(isAnimated ? 1.0 : 0.0)
                        .offset(y: isAnimated ? 0 : 6)
                    
                    Text("INTERACTIVE TIMELINES")
                        .font(AppTheme.appTagline)
                        .foregroundStyle(.secondary)
                        .tracking(AppTheme.taglineTracking)
                        .opacity(isAnimated ? 1.0 : 0.0)
                        .offset(y: isAnimated ? 0 : 4)
                    
                    HStack(spacing: 0) {
                        Circle()
                            .fill(AppTheme.roseGoldDark.opacity(AppTheme.accentOpacity))
                            .frame(width: 6, height: 6)
                        
                        Rectangle()
                            .fill(AppTheme.roseGoldLight.opacity(AppTheme.accentOpacity))
                            .frame(height: AppTheme.regularLineWidth)
                            .frame(maxWidth: isAnimated ? 180 : 0)
                        
                        Image(systemName: "heart.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.roseGoldDark)
                            .padding(.horizontal, isAnimated ? 18 : 0)
                            .scaleEffect(isAnimated ? heartScale : 0.0)
                        
                        Rectangle()
                            .fill(AppTheme.roseGoldLight.opacity(AppTheme.accentOpacity))
                            .frame(height: AppTheme.regularLineWidth)
                            .frame(maxWidth: isAnimated ? 180 : 0)
                        
                        Circle()
                            .fill(AppTheme.roseGoldDark.opacity(AppTheme.accentOpacity))
                            .frame(width: 6, height: 6)
                    }
                    .padding(.top, 12)
                    .frame(maxWidth: 460)
                }
                
                VStack {
                    SignInWithAppleButton(.signIn, onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    }, onCompletion: { result in
                        handleAppleSignInCompletion(result: result)
                    })
                    .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                    .frame(width: AppTheme.authButtonWidth, height: AppTheme.authButtonHeight)
                    .opacity(isAnimated ? 1.0 : 0.0)
                }
                .padding(.top, 54)
                
                Spacer()
            }
            .padding(.horizontal, 40)
        }
        // DEDICATION PLACARD
        .overlay(alignment: .bottomTrailing) {
            Text("By Priyanka, For Shrey")
                .font(AppTheme.dedicationPlacard)
                .foregroundStyle(AppTheme.roseGoldDark.opacity(AppTheme.mutedTextOpacity))
                .tracking(AppTheme.placardTracking)
                .opacity(isAnimated ? 1.0 : 0.0)
                .padding(.trailing, 60)
                .padding(.bottom, 40)
        }
        .frame(minWidth: 680, idealWidth: 760, maxWidth: .infinity, minHeight: 420, idealHeight: 480, maxHeight: .infinity)
        .onAppear {
            withAnimation(.spring(response: 0.9, dampingFraction: 0.8)) {
                isAnimated = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.interpolatingSpring(stiffness: 100, damping: 10)) {
                    heartScale = 1.25
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    withAnimation(.spring()) {
                        heartScale = 1.0
                    }
                }
            }
        }
    }
    
    private func handleAppleSignInCompletion(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let appleIDCredential = auth.credential as? ASAuthorizationAppleIDCredential {
                let userIdentifier = appleIDCredential.user
                let fullName = appleIDCredential.fullName
                let email = appleIDCredential.email
                
                var tokenString = ""
                if let identityToken = appleIDCredential.identityToken {
                    tokenString = String(data: identityToken, encoding: .utf8) ?? ""
                }
                
                let actualPayload = [
                    "appleUserId": userIdentifier,
                    "identityToken": tokenString,
                    "email": email ?? "",
                    "firstName": fullName?.givenName ?? "",
                    "lastName": fullName?.familyName ?? ""
                ]
                
                authenticateUserWithBackend(payload: actualPayload)
            }
            
        case .failure(let error):
            print("Sign in cancelled or failed: \(error.localizedDescription)")
        }
    }
    
    private func authenticateUserWithBackend(payload: [String: String]) {
        guard let url = URL(string: "http://localhost:3000/api/auth/apple") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let token = json["token"] as? String {
                    appState.authToken = token
                    EventService.shared.authToken = token
                    JourneyService.shared.authToken = token
                }
                appState.isLoggedIn = true
            }
        }.resume()
    }
}

#Preview {
    LoginView()
        .environment(AppState())
}
