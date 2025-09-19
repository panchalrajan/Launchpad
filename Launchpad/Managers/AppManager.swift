import Foundation
import AppKit

final class AppManager {
    nonisolated(unsafe) static let shared = AppManager()
    
    private let userDefaults = UserDefaults.standard
    private let gridItemsKey = "LaunchpadGridItems"
    
    func loadGridItems(appsPerPage: Int = 35) -> [AppGridItem] {
        let apps = discoverApps()
        return loadFromUserDefaults(for: apps, appsPerPage: appsPerPage)
    }
    
    func saveGridItems(_ items: [AppGridItem]) {
        let itemsData = items.map { item -> [String: Any] in
            switch item {
            case .app(let app):
                return [
                    "type": "app",
                    "id": app.id.uuidString,
                    "name": app.name,
                    "path": app.path,
                    "page": app.page
                ]
            case .folder(let folder):
                let appsData = folder.apps.map { app in
                    [
                        "id": app.id.uuidString,
                        "name": app.name,
                        "path": app.path,
                        "page": app.page
                    ]
                }
                return [
                    "type": "folder",
                    "id": folder.id.uuidString,
                    "name": folder.name,
                    "page": folder.page,
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
                foundApps.append(AppInfo(name: appName, icon: icon, path: fullPath, page: 0))
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
    
    private func loadFromUserDefaults(for apps: [AppInfo], appsPerPage: Int) -> [AppGridItem] {
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
                   let baseApp = appsByPath[path] {
                    let savedPage = itemData["page"] as? Int ?? 0
                    let appWithPage = AppInfo(name: baseApp.name, icon: baseApp.icon, path: baseApp.path, page: savedPage)
                    gridItems.append(.app(appWithPage))
                    usedPaths.insert(path)
                }
                
            case "folder":
                if let folderName = itemData["name"] as? String,
                   let appsData = itemData["apps"] as? [[String: Any]] {
                    
                    var folderApps: [AppInfo] = []
                    for appData in appsData {
                        if let path = appData["path"] as? String,
                           let baseApp = appsByPath[path] {
                            let savedPage = appData["page"] as? Int ?? 0
                            let appWithPage = AppInfo(name: baseApp.name, icon: baseApp.icon, path: baseApp.path, page: savedPage)
                            folderApps.append(appWithPage)
                            usedPaths.insert(path)
                        }
                    }
                    
                    if !folderApps.isEmpty {
                        let savedPage = itemData["page"] as? Int ?? 0
                        let folder = Folder(name: folderName, page: savedPage, apps: folderApps)
                        gridItems.append(.folder(folder))
                    }
                }
            default:
                break
            }
        }
        
        // Add any new apps that weren't in the saved data with page 0
        for app in apps where !usedPaths.contains(app.path) {
            let appWithPage = AppInfo(name: app.name, icon: app.icon, path: app.path, page: 0)
            gridItems.append(.app(appWithPage))
        }
        
        // Redistribute items if any page exceeds the limit
        return redistributeItemsToFitPageLimits(gridItems, appsPerPage: appsPerPage)
    }
    
    private func redistributeItemsToFitPageLimits(_ items: [AppGridItem], appsPerPage: Int) -> [AppGridItem] {
        // Group items by page
        let groupedByPage = Dictionary(grouping: items) { $0.page }
        var redistributedItems: [AppGridItem] = []
        
        // Process pages in order
        let sortedPages = groupedByPage.keys.sorted()
        var currentPage = 0
        var itemsOnCurrentPage = 0
        
        for pageNum in sortedPages {
            let pageItems = groupedByPage[pageNum] ?? []
            
            for item in pageItems {
                // If current page is full, move to next page
                if itemsOnCurrentPage >= appsPerPage {
                    currentPage += 1
                    itemsOnCurrentPage = 0
                }
                
                // Update item's page if needed
                var updatedItem = item
                if item.page != currentPage {
                    switch item {
                    case .app(let app):
                        updatedItem = .app(AppInfo(name: app.name, icon: app.icon, path: app.path, page: currentPage))
                    case .folder(let folder):
                        updatedItem = .folder(Folder(name: folder.name, page: currentPage, apps: folder.apps))
                    }
                }
                
                redistributedItems.append(updatedItem)
                itemsOnCurrentPage += 1
            }
        }
        
        return redistributedItems
    }
}
