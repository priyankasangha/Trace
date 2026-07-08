import SwiftUI

@Observable
class AppState {
    // Tracks whether the user is authenticated. Starts as false.
    var isLoggedIn: Bool = false
    
    // JWT token from backend, sent with API requests
    var authToken: String? = nil
    
    // Navigation: when non-nil, the app shows the timeline for this journey.
    var selectedJourney: JourneyItem? = nil
    
    /// Sets the JWT on all services and persists to Keychain
    func configureAuth(token: String) {
        authToken = token
        EventService.shared.authToken = token
        JourneyService.shared.authToken = token
        KeychainHelper.saveToken(token)
        isLoggedIn = true
    }
    
    /// Attempts to restore a saved session from Keychain
    func restoreSession() -> Bool {
        guard let token = KeychainHelper.loadToken() else { return false }
        authToken = token
        EventService.shared.authToken = token
        JourneyService.shared.authToken = token
        isLoggedIn = true
        return true
    }
    
    /// Clears auth state and Keychain
    func logout() {
        authToken = nil
        EventService.shared.authToken = nil
        JourneyService.shared.authToken = nil
        KeychainHelper.deleteToken()
        isLoggedIn = false
        selectedJourney = nil
    }
}
