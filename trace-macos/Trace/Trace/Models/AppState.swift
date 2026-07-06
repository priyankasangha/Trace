import SwiftUI

@Observable
class AppState {
    // Tracks whether the user is authenticated. Starts as false.
    var isLoggedIn: Bool = false
    
    // Auth token from backend, sent with API requests
    var authToken: String? = nil
    
    // Navigation: when non-nil, the app shows the timeline for this journey.
    var selectedJourney: JourneyItem? = nil
}
