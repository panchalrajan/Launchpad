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
        let gridItems = AppManager.shared.loadGridItems(appsPerPage: settingsManager.settings.appsPerPage)
        gridItemPages = groupItemsByPage(gridItems)
    }
    
    private func groupItemsByPage(_ items: [AppGridItem]) -> [[AppGridItem]] {
        let groupedDict = Dictionary(grouping: items) { $0.page }
        let maxPage = groupedDict.keys.max() ?? 0
        
        var pages: [[AppGridItem]] = []
        for pageIndex in 0...maxPage {
            let pageItems = groupedDict[pageIndex] ?? []
            if !pageItems.isEmpty || pageIndex == 0 {
                pages.append(pageItems)
            }
        }
        
        return pages.isEmpty ? [[]] : pages
    }
    
    private func saveGridItems(from pages: [[AppGridItem]]) {
        AppManager.shared.saveGridItems(pages.flatMap { $0 })
    }
    
    private func clearGridItems() {
        AppManager.shared.clearGridItems()
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
