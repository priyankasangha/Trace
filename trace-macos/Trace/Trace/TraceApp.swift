//
//  TraceApp.swift
//  Trace
//
//  Created by Priyanka Sangha on 2026-05-26.
//

import SwiftUI

@main
struct TraceApp: App {
    @State private var appState = AppState()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State private var recentActivities: [ActivityLogItem] = [
        ActivityLogItem(message: "Updated timeline constraints", timestamp: "Just now"),
        ActivityLogItem(message: "Shared 'Summer in Europe' context", timestamp: "2 hours ago")
    ]
    
    
    var body: some Scene {
        WindowGroup {
            if !appState.isLoggedIn {
                LoginView()
                    .environment(appState)
                    .onAppear {
                        // Try to restore saved JWT session
                        _ = appState.restoreSession()
                    }
            } else if let journey = appState.selectedJourney {
                TimelineCanvasView(
                    journeyTitle: journey.title,
                    journeyDescription: journey.description,
                    journeyId: journey.apiId ?? 1,
                    onBack: { appState.selectedJourney = nil }
                )
            } else {
                JourneysViews(
                    recentActivities: recentActivities,
                    onOpenJourney: { journey in
                        appState.selectedJourney = journey
                    }
                )
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.styleMask.insert(.fullSizeContentView)
            window.toolbar = nil
        }
    }
}

