import SwiftUI

@main
struct CritiqueApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var appState = AppState.shared
    @State private var settings = AppSettings.shared
    
    var body: some Scene {
        // Menu bar extra provides the status item and dropdown menu
        MenuBarExtra {
            MenuBarMenu(appState: appState, settings: settings)
        } label: {
            Image("MenuBarIcon")
        }
        .menuBarExtraStyle(.menu)
        
        // Settings scene for the preferences window
        Settings {
            SettingsView(appState: appState, showOnlyApiSetup: false)
        }
    }
}

// MARK: - Menu Bar Menu Content

struct MenuBarMenu: View {
    @Bindable var appState: AppState
    @Bindable var settings: AppSettings
    @Environment(\.openSettings) private var openSettings
    
    var body: some View {
        Button("Settings") {
            openSettings()
            Task { @MainActor in
                await Task.yield()
                if let settingsWindow = NSApp.windows.first(where: {
                    $0.identifier?.rawValue == "com_apple_SwiftUI_Settings_window"
                        || $0.title.contains("Settings")
                }), settingsWindow.isVisible {
                    WindowManager.shared.bringWindowToFront(settingsWindow)
                }
            }
        }
        .keyboardShortcut(",", modifiers: .command)
                
        Button(settings.hotkeysPaused ? "Resume Hotkeys" : "Pause Hotkeys") {
            settings.hotkeysPaused.toggle()
        }
        
        Divider()

        Button("About Critique") {
            showAboutWindow()
        }
        
        Divider()
        
        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: .command)
    }
    
    @State private var aboutWindow: NSWindow?

    private func showAboutWindow() {
        // Reuse existing window if it's still open
        if let existing = aboutWindow, existing.isVisible {
            WindowManager.shared.bringWindowToFront(existing)
            return
        }

        let aboutView = AboutView()
        let hostingView = NSHostingView(rootView: aboutView)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 400),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.identifier = NSUserInterfaceItemIdentifier("AboutWindow")
        window.isReleasedWhenClosed = false
        window.contentView = hostingView
        window.title = "About"
        window.center()

        WindowManager.shared.bringWindowToFront(window)
        aboutWindow = window
    }
}
