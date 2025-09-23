import SwiftUI

@main
struct LaunchpadApp: App {
    @StateObject private var settingsManager = SettingsManager.shared
    @StateObject private var appManager = AppManager.shared
    @State private var showSettings = false
    @State private var importAlertMessage: String?
    
    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .topTrailing) {
                WindowAccessor()
                PagedGridView(
                    pages: $appManager.pages,
                    settings: settingsManager.settings,
                )
                .onAppear {
                    loadGridItems()
                    subscribeToSystemEvents()
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                }
                .onTapGesture {
                    AppLauncher.exit()
                }
            }
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(after: .appInfo) {
                Button("Settings") {
                    showSettings = true
                }
                Divider()
                Button("Import from Launchpad") {
                }
                Button("Clear Grid Items") {
                    clearGridItems()
                }
            }
        }
    }
    
    private func loadGridItems() {
        appManager.loadGridItems(appsPerPage: settingsManager.settings.appsPerPage)
    }
    
    private func saveGridItems(from pages: [[AppGridItem]]) {
        appManager.pages = pages
    }
    
    private func clearGridItems() {
        appManager.clearGridItems(appsPerPage: settingsManager.settings.appsPerPage)
    }
    
    private func subscribeToSystemEvents() {
        // Subscribe to app opened
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: .main
        ) { notification in
            if let info = notification.userInfo,
               let activatedApp = info[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
            {
                if activatedApp.bundleIdentifier != Bundle.main.bundleIdentifier {
                    Task { @MainActor in
                        print(
                            "Exiting Launchpad because \(activatedApp.bundleIdentifier ?? "unknown") was activated"
                        )
                        AppLauncher.exit()
                    }
                }
            }
        }
    }
}
