import SwiftUI

@Observable
class AppState {
    // Tracks whether the user is authenticated. Starts as false.
    var isLoggedIn: Bool = false
}
