import Foundation
import AppKit

final class AppManager {
    nonisolated(unsafe) static let shared = AppManager()
    
    private let userDefaults = UserDefaults.standard
    private let gridItemsKey = "LaunchpadGridItems"
    
    func loadGridItems() -> [AppGridItem] {
        let apps = discoverApps()
        return loadFromUserDefaults(for: apps)
    }
    
    func saveGridItems(_ items: [AppGridItem]) {
        let itemsData = items.map { item -> [String: Any] in
            switch item {
            case .app(let app):
                return [
                    "type": "app",
                    "id": app.id.uuidString,
                    "name": app.name,
                    "path": app.path
                ]
            case .folder(let folder):
                let appsData = folder.apps.map { app in
                    [
                        "id": app.id.uuidString,
                        "name": app.name,
                        "path": app.path
                    ]
                }
                return [
                    "type": "folder",
                    "id": folder.id.uuidString,
                    "name": folder.name,
                    "color": folder.color.rawValue,
                    "apps": appsData
                ]
            }
        }
        
        userDefaults.set(itemsData, forKey: gridItemsKey)
        userDefaults.synchronize()
    }
    
    func clearGridItems() {
        userDefaults.removeObject(forKey: gridItemsKey)
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
    
    private func loadFromUserDefaults(for apps: [AppInfo]) -> [AppGridItem] {
        guard let savedData = userDefaults.array(forKey: gridItemsKey) as? [[String: Any]] else {
            // Convert apps to AppGridItems if no saved data
            return apps.map { .app($0) }
        }
        
        // Create a dictionary for quick lookup of apps by path
        let appsByPath = Dictionary(uniqueKeysWithValues: apps.map { ($0.path, $0) })
        
        var gridItems: [AppGridItem] = []
        var usedPaths = Set<String>()
        
        // Reconstruct grid items from saved data
        for itemData in savedData {
            guard let type = itemData["type"] as? String else { continue }
            
            switch type {
            case "app":
                if let path = itemData["path"] as? String,
                   let app = appsByPath[path] {
                    gridItems.append(.app(app))
                    usedPaths.insert(path)
                }
                
            case "folder":
                if let folderName = itemData["name"] as? String,
                   let colorRaw = itemData["color"] as? String,
                   let color = FolderColor(rawValue: colorRaw),
                   let appsData = itemData["apps"] as? [[String: String]] {
                    
                    var folderApps: [AppInfo] = []
                    for appData in appsData {
                        if let path = appData["path"],
                           let app = appsByPath[path] {
                            folderApps.append(app)
                            usedPaths.insert(path)
                        }
                    }
                    
                    if !folderApps.isEmpty {
                        let folder = Folder(name: folderName, apps: folderApps, color: color)
                        gridItems.append(.folder(folder))
                    }
                }
            default:
                break
            }
        }
        
        // Add any new apps that weren't in the saved data
        for app in apps where !usedPaths.contains(app.path) {
            gridItems.append(.app(app))
        }
        
        return gridItems
    }
}
