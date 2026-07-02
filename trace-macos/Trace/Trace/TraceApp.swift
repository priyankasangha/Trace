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
    
    // TODO: these are still hardcoded mock data, same as before — just
    // promoted to @State so `journeys` has something real to bind to for
    // delete/edit. Once the backend is wired up (last on the list), these
    // should probably be sourced from `appState` instead of living here.
    @State private var showCreateSheet = false
    @State private var journeys: [JourneyItem] = [
        JourneyItem(title: "Summer in Europe", description: "Exploring coastal cities, train transfers, and shared highlights.", dateRangeString: "05/12/2026 — Ongoing", collaboratorCount: 3, coverImageName: nil, isOngoing: true),
        JourneyItem(title: "Trace Architecture Shift", description: "Documenting the transition from JavaScript to native SwiftUI states.", dateRangeString: "04/01/2026 — 05/20/2026", collaboratorCount: 1, coverImageName: nil, isOngoing: false)
    ]
    @State private var recentActivities: [ActivityLogItem] = [
        ActivityLogItem(message: "Updated timeline constraints", timestamp: "Just now"),
        ActivityLogItem(message: "Shared 'Summer in Europe' context", timestamp: "2 hours ago")
    ]
    
    var body: some Scene {
        WindowGroup {
            if let journey = appState.selectedJourney {
                TimelineCanvasView(
                    journeyTitle: journey.title,
                    journeyDescription: journey.description,
                    onBack: { appState.selectedJourney = nil }
                )
            } else {
                JourneysViews(
                    journeys: $journeys,
                    recentActivities: recentActivities,
                    showCreateSheet: $showCreateSheet,
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

