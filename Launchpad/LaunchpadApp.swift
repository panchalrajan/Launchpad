import SwiftUI

@main
struct LaunchpadApp: App {
    private var settingsManager = SettingsManager.shared
    private var appManager = AppManager.shared
    private var appLauncher = AppLauncher.shared
    @State private var gridItemPages: [[AppGridItem]] = []
    @State private var showSettings = false
    
    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .topTrailing) {
                WindowAccessor()
                PagedGridView(
                    pages: $gridItemPages,
                    columns: settingsManager.settings.columns,
                    rows: settingsManager.settings.rows,
                    iconSize: settingsManager.settings.iconSize,
                    dropDelay: settingsManager.settings.dropDelay
                )
                .ignoresSafeArea()
                .onAppear {
                    loadGridItems()
                    subscribeToSystemEvents()
                }
                .onChange(of: settingsManager.settings) { oldSettings, newSettings in
                    loadGridItems()
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                        .interactiveDismissDisabled(false)
                }
                .onTapGesture {
                    AppLauncher.shared.exit()
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
                Button("Clear Grid Items") {
                    clearGridItems()
                }
            }
        }
    }
    
    private func loadGridItems() {
        gridItemPages = appManager.loadGridItems(appsPerPage: settingsManager.settings.appsPerPage)
    }
    
    private func saveGridItems(from pages: [[AppGridItem]]) {
        appManager.saveGridItems(items: pages.flatMap { $0 })
    }
    
    private func clearGridItems() {
        appManager.clearGridItems()
        NSApp.terminate(nil)
    }
    
    private func subscribeToSystemEvents(){
        // Subscribe to app opened
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: .main) { notification in
            if let info = notification.userInfo,
               let activatedApp = info[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                if activatedApp.bundleIdentifier != Bundle.main.bundleIdentifier {
                    Task { @MainActor in
                        appLauncher.exit()
                    }
                }
            }
        }
    }
}
