import SwiftUI

@main
struct LaunchpadApp: App {
    @State private var apps: [AppInfo] = []
    @State private var appPages: [[AppInfo]] = []
    
    private let appsPerPage = 35
    
    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .topTrailing) {
                WindowAccessor()
                PagedGridView(pages: $appPages)
                    .ignoresSafeArea()
                    .onAppear {
                        loadApps()
                    }
                    .onChange(of: appPages) { oldPages, newPages in
                        saveAppOrder(from: newPages)
                    }
            }
        }
        .windowStyle(.hiddenTitleBar)
    }
    
    private func loadApps() {
        apps = discoverApps()
        let orderedApps = AppOrderManager.shared.loadAppOrder(for: apps)
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
