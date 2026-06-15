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
    
    var body: some Scene {
        WindowGroup {
            TimelineCanvasView(journeyTitle: "Test Journey", journeyDescription: "Test Descripton")
                .environment(appState)
                .background(WindowConfigurator())
        }
    }
}

struct WindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                context.coordinator.configure(window)
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        if let window = nsView.window {
            context.coordinator.configure(window)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, NSWindowDelegate {
        weak var window: NSWindow?
        
        func configure(_ window: NSWindow) {
            self.window = window
            window.delegate = self
            applyNativeStyles(window)
        }
        
        func windowWillExitFullScreen(_ notification: Notification) {
            if let window = self.window {
                applyNativeStyles(window)
            }
        }
        
        func windowDidExitFullScreen(_ notification: Notification) {
            if let window = self.window {
                applyNativeStyles(window)
            }
        }
        
        private func applyNativeStyles(_ window: NSWindow) {
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            
            if !window.styleMask.contains(.fullSizeContentView) {
                window.styleMask.insert(.fullSizeContentView)
            }
            
            window.toolbar = nil
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
