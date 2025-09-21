import SwiftUI

@main
struct LaunchpadApp: App {
    private var settingsManager = SettingsManager.shared
    private var appManager = AppManager.shared
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
                    setupNotificationObserver()
                }
                .onChange(of: gridItemPages) { oldPages, newPages in
                    saveGridItems(from: newPages)
                }
                .onChange(of: settingsManager.settings) { oldSettings, newSettings in
                    loadGridItems()
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                        .interactiveDismissDisabled(false)
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
        appManager.saveGridItems(pages.flatMap { $0 })
    }
    
    private func clearGridItems() {
        appManager.clearGridItems()
        NSApp.terminate(nil)
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("SaveGridItems"),
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                saveGridItems(from: gridItemPages)
            }
        }
    }
}
