import Foundation

enum StorageType {
    case userDefaults
    case coreData
}

final class AppOrderManager {
    nonisolated(unsafe) static let shared = AppOrderManager()
    
    private let userDefaults = UserDefaults.standard
    private let appOrderKey = "LaunchpadAppOrder"
    private let storageType: StorageType = .userDefaults
    
    func saveAppOrder(_ apps: [AppInfo]) {
        switch storageType {
        case .userDefaults:
            saveToUserDefaults(apps)
        case .coreData:
            CoreDataAppOrderManager.shared.saveAppOrder(apps)
        }
    }
    
    func loadAppOrder(for apps: [AppInfo]) -> [AppInfo] {
        switch storageType {
        case .userDefaults:
            return loadFromUserDefaults(for: apps)
        case .coreData:
            return CoreDataAppOrderManager.shared.loadAppOrder(for: apps)
        }
    }
    
    func clearAppOrder() {
        switch storageType {
        case .userDefaults:
            clearUserDefaults()
        case .coreData:
            CoreDataAppOrderManager.shared.clearAppOrder()
        }
    }
    
    private func saveToUserDefaults(_ apps: [AppInfo]) {
        let appData = apps.map { app in
            [
                "id": app.id.uuidString,
                "name": app.name,
                "path": app.path
            ]
        }
        
        userDefaults.set(appData, forKey: appOrderKey)
        userDefaults.synchronize()
        print("App order saved to UserDefaults with \(apps.count) apps")
    }
    
    private func loadFromUserDefaults(for apps: [AppInfo]) -> [AppInfo] {
        guard let savedData = userDefaults.array(forKey: appOrderKey) as? [[String: String]] else {
            print("No saved app order found in UserDefaults, using default order")
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
        
        print("App order loaded from UserDefaults with \(orderedApps.count) apps (\(savedData.count) from saved order)")
        return orderedApps
    }
    
    private func clearUserDefaults() {
        userDefaults.removeObject(forKey: appOrderKey)
        userDefaults.synchronize()
        print("App order cleared from UserDefaults")
    }
}
