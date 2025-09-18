import SwiftUI

@main
struct LaunchpadApp: App {
    @StateObject private var settingsManager = SettingsManager.shared
    @State private var apps: [AppInfo] = []
    @State private var appPages: [[AppInfo]] = []
    @State private var showSettings = false
    
    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .topTrailing) {
                WindowAccessor()
                PagedGridView(
                    pages: $appPages,
                    columns: settingsManager.settings.columns, 
                    rows: settingsManager.settings.rows
                )
                .ignoresSafeArea()
                .onAppear {
                    loadApps()
                }
                .onChange(of: appPages) { oldPages, newPages in
                    saveAppOrder(from: newPages)
                }
                .onChange(of: settingsManager.settings) { oldSettings, newSettings in
                    loadApps()
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
    
    private func loadApps() {
        apps = discoverApps()
        let orderedApps = AppOrderManager.shared.loadAppOrder(for: apps)
        let appsPerPage = settingsManager.settings.appsPerPage
        appPages = orderedApps.chunked(into: appsPerPage)
    }
    
    private func saveAppOrder(from pages: [[AppInfo]]) {
        let newAppsOrder = pages.flatMap { $0 }
        apps = newAppsOrder
        AppOrderManager.shared.saveAppOrder(newAppsOrder)
    }
    
    private func discoverApps() -> [AppInfo] {
        let appPaths = ["/Applications", "/System/Applications"]
        var foundApps: [AppInfo] = []
        
        for basePath in appPaths {
            guard let contents = try? FileManager.default.contentsOfDirectory(atPath: basePath) else {
                continue
            }
            
            for item in contents where item.hasSuffix(".app") {
                let fullPath = basePath + "/" + item
                let appName = item.replacingOccurrences(of: ".app", with: "")
                let icon = NSWorkspace.shared.icon(forFile: fullPath)
                icon.size = NSSize(width: 64, height: 64)
                foundApps.append(AppInfo(name: appName, icon: icon, path: fullPath))
            }
        }
        
        return foundApps.sorted { $0.name.lowercased() < $1.name.lowercased() }
    }
}
