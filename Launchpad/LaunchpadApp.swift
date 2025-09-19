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
                    iconSize: settingsManager.settings.iconSize,
                    dropDelay: settingsManager.settings.dropDelay
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
                Divider()
                Button("Clear Grid Items") {
                    clearGridItems()
                }
            }
        }
    }
    
    private func loadGridItems() {
        let gridItems = AppManager.shared.loadGridItems(appsPerPage: settingsManager.settings.appsPerPage)
        gridItemPages = groupItemsByPage(gridItems)
    }
    
    private func groupItemsByPage(_ items: [AppGridItem]) -> [[AppGridItem]] {
        // Group items by their page attribute
        let groupedDict = Dictionary(grouping: items) { $0.page }
        
        // Convert to sorted array of pages
        let maxPage = groupedDict.keys.max() ?? 0
        var pages: [[AppGridItem]] = []
        
        for pageIndex in 0...maxPage {
            let pageItems = groupedDict[pageIndex] ?? []
            if !pageItems.isEmpty || pageIndex == 0 {
                pages.append(pageItems)
            }
        }
        
        // Ensure we have at least one page
        if pages.isEmpty {
            pages.append([])
        }
        
        return pages
    }
    
    private func saveGridItems(from pages: [[AppGridItem]]) {
        let gridItems = pages.flatMap { $0 }
        AppManager.shared.saveGridItems(gridItems)
    }
    
    private func clearGridItems() {
        AppManager.shared.clearGridItems()
        NSApp.terminate(nil)
    }
}
