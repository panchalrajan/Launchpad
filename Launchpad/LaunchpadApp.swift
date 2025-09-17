import SwiftUI

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

@main
struct LaunchpadApp: App {
    @State private var apps: [AppInfo] = Self.loadApps()
    @State private var appPages: [[AppInfo]] = []
    
    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .topTrailing) {
                WindowAccessor()
                PagedGridView(pages: $appPages)
                    .frame(minWidth: 800, minHeight: 600)
                    .ignoresSafeArea()
                    .onAppear {
                        appPages = apps.chunked(into: 35)
                    }
                    .onChange(of: appPages) { oldPages, newPages in
                        // Flatten pages back to apps array when order changes
                        let newAppsOrder = newPages.flatMap { $0 }
                        apps = newAppsOrder
                        // Save the new order to persistent storage
                        AppOrderManager.shared.saveAppOrder(newAppsOrder)
                    }
            }
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Reset App Order") {
                    AppOrderManager.shared.clearAppOrder()
                    // Reload apps in default order
                    let defaultApps = Self.loadDefaultApps()
                    apps = defaultApps
                    appPages = defaultApps.chunked(into: 35)
                }
                .keyboardShortcut("r", modifiers: [.command, .shift])
            }
        }
    }

    static func loadApps() -> [AppInfo] {
        let appPaths = ["/Applications", "/System/Applications"]
        var foundApps: [AppInfo] = []
        for basePath in appPaths {
            guard let contents = try? FileManager.default.contentsOfDirectory(atPath: basePath) else { continue }
            for item in contents where item.hasSuffix(".app") {
                let fullPath = basePath + "/" + item
                let appName = item.replacingOccurrences(of: ".app", with: "")
                let icon = NSWorkspace.shared.icon(forFile: fullPath)
                icon.size = NSSize(width: 64, height: 64)
                foundApps.append(AppInfo(name: appName, icon: icon, path: fullPath))
            }
        }
        
        // Sort apps alphabetically first, then apply saved order
        let sortedApps = foundApps.sorted { $0.name.lowercased() < $1.name.lowercased() }
        
        // Load and apply saved app order
        return AppOrderManager.shared.loadAppOrder(for: sortedApps)
    }
    
    static func loadDefaultApps() -> [AppInfo] {
        let appPaths = ["/Applications", "/System/Applications"]
        var foundApps: [AppInfo] = []
        for basePath in appPaths {
            guard let contents = try? FileManager.default.contentsOfDirectory(atPath: basePath) else { continue }
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
