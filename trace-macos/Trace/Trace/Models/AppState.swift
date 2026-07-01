import SwiftUI

@Observable
class AppState {
    // Tracks whether the user is authenticated. Starts as false.
    var isLoggedIn: Bool = false
    
    // Navigation: when non-nil, the app shows the timeline for this journey.
    var selectedJourney: JourneyItem? = nil
}
