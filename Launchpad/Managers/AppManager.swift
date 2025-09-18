import Foundation
import AppKit

final class AppManager {
    nonisolated(unsafe) static let shared = AppManager()
    
    private let userDefaults = UserDefaults.standard
    private let appOrderKey = "LaunchpadAppOrder"
    
    func loadAppOrder() -> [AppInfo] {
        let apps = discoverApps()
        return loadFromUserDefaults(for: apps)
    }
    
    func saveAppOrder(_ apps: [AppInfo]) {
        let appList = apps.map { app in
            [
                "id": app.id.uuidString,
                "name": app.name,
                "path": app.path
            ]
        }
        
        userDefaults.set(appList, forKey: appOrderKey)
        userDefaults.synchronize()
    }
    
    func clearAppOrder() {
        userDefaults.removeObject(forKey: appOrderKey)
        userDefaults.synchronize()
    }
    
    private func discoverApps() -> [AppInfo] {
        let appPaths = ["/Applications", "/System/Applications"]
        var foundApps: [AppInfo] = []
        
        for basePath in appPaths {
            foundApps.append(contentsOf: discoverAppsRecursively(in: basePath))
        }
        
        return foundApps.sorted { $0.name.lowercased() < $1.name.lowercased() }
    }
    
    private func discoverAppsRecursively(in directory: String, maxDepth: Int = 3, currentDepth: Int = 0) -> [AppInfo] {
        // Prevent infinite recursion and limit search depth
        guard currentDepth < maxDepth else { return [] }
        
        var foundApps: [AppInfo] = []
        
        guard let contents = try? FileManager.default.contentsOfDirectory(atPath: directory) else {
            return foundApps
        }
        
        for item in contents {
            let fullPath = directory + "/" + item
            
            if item.hasSuffix(".app") {
                // Found an app, add it to the list
                let appName = item.replacingOccurrences(of: ".app", with: "")
                let icon = NSWorkspace.shared.icon(forFile: fullPath)
                icon.size = NSSize(width: 64, height: 64)
                foundApps.append(AppInfo(name: appName, icon: icon, path: fullPath))
            } else {
                // Check if it's a directory and recursively search it
                var isDirectory: ObjCBool = false
                if FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDirectory),
                   isDirectory.boolValue {
                    // Skip certain system directories to avoid performance issues
                    let skipDirectories = [".Trash", "Utilities", ".DS_Store", ".localized"]
                    if !skipDirectories.contains(item) && !item.hasPrefix(".") {
                        foundApps.append(contentsOf: discoverAppsRecursively(
                            in: fullPath,
                            maxDepth: maxDepth,
                            currentDepth: currentDepth + 1
                        ))
                    }
                }
            }
        }
        
        return foundApps
    }
    
    private func loadFromUserDefaults(for apps: [AppInfo]) -> [AppInfo] {
        guard let savedData = userDefaults.array(forKey: appOrderKey) as? [[String: String]] else {
            return apps
        }
        
        // Create a dictionary for quick lookup of apps by path
        let appsByPath = Dictionary(uniqueKeysWithValues: apps.map { ($0.path, $0) })
        
        var orderedApps: [AppInfo] = []
        var usedPaths = Set<String>()
        
        // First, add apps in saved order
        for savedApp in savedData {
            if let path = savedApp["path"],
               let app = appsByPath[path] {
                orderedApps.append(app)
                usedPaths.insert(path)
            }
        }
        
        // Then, add any new apps that weren't in the saved order
        for app in apps where !usedPaths.contains(app.path) {
            orderedApps.append(app)
        }
        
        return orderedApps
    }
}
