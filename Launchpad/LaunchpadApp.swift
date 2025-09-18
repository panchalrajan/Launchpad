import SwiftUI

@main
struct LaunchpadApp: App {
    @StateObject private var settingsManager = SettingsManager.shared
    @State private var appPages: [[AppInfo]] = []
    @State private var showSettings = false
    
    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .topTrailing) {
                WindowAccessor()
                PagedGridView(
                    pages: $appPages,
                    columns: settingsManager.settings.columns, 
                    rows: settingsManager.settings.rows,
                    iconSizeMultiplier: settingsManager.settings.iconSizeMultiplier
                )
                .ignoresSafeArea()
                .onAppear {
                    loadAppOrder()
                }
                .onChange(of: appPages) { oldPages, newPages in
                    saveAppOrder(from: newPages)
                }
                .onChange(of: settingsManager.settings) { oldSettings, newSettings in
                    loadAppOrder()
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
            }
        }
    }
    
    private func loadAppOrder() {
        let orderedApps = AppManager.shared.loadAppOrder()
        appPages = orderedApps.chunked(into: settingsManager.settings.appsPerPage)
    }
    
    private func saveAppOrder(from pages: [[AppInfo]]) {
        let orderedApps = pages.flatMap { $0 }
        AppManager.shared.saveAppOrder(orderedApps)
    }
}
