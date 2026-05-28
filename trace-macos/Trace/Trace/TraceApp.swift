//
//  TraceApp.swift
//  Trace
//
//  Created by Priyanka Sangha on 2026-05-26.
//

import SwiftUI

@main
struct TraceApp: App {
    var body: some Scene {
        WindowGroup {
            LoginView()
                .environment(AppState())
        }
    }
}
