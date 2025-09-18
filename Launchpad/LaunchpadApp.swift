import SwiftUI

@main
struct LaunchpadApp: App {
    @StateObject private var settingsManager = SettingsManager.shared
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
                    iconSizeMultiplier: settingsManager.settings.iconSizeMultiplier
                )
                .ignoresSafeArea()
                .onAppear {
                    loadGridItems()
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
            }
        }
    }
    
    private func loadGridItems() {
        let gridItems = AppManager.shared.loadGridItems()
        gridItemPages = gridItems.chunked(into: settingsManager.settings.appsPerPage)
    }
    
    private func saveGridItems(from pages: [[AppGridItem]]) {
        let gridItems = pages.flatMap { $0 }
        AppManager.shared.saveGridItems(gridItems)
    }
}
