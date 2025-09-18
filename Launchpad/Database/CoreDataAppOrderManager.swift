import CoreData
import Foundation

class CoreDataManager {
    nonisolated(unsafe) static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "LaunchpadModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data error: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Save error: \(error)")
            }
        }
    }
}

class CoreDataAppOrderManager {
    nonisolated(unsafe) static let shared = CoreDataAppOrderManager()
    private let coreData = CoreDataManager.shared
    
    private init() {}
    
    /// Save app order to Core Data
    func saveAppOrder(_ apps: [AppInfo]) {
        let context = coreData.context
        
        // Clear existing records
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = AppOrderEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            
            // Save new order
            for (index, app) in apps.enumerated() {
                let entity = AppOrderEntity(context: context)
                entity.appPath = app.path
                entity.orderIndex = Int32(index)
                entity.dateModified = Date()
            }
            
            coreData.save()
            print("App order saved to Core Data with \(apps.count) apps")
        } catch {
            print("Error saving app order: \(error)")
        }
    }
    
    /// Load app order from Core Data
    func loadAppOrder(for apps: [AppInfo]) -> [AppInfo] {
        let context = coreData.context
        let fetchRequest: NSFetchRequest<AppOrderEntity> = AppOrderEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
        
        do {
            let savedOrder = try context.fetch(fetchRequest)
            
            if savedOrder.isEmpty {
                print("No saved app order found in Core Data")
                return apps
            }
            
            // Create lookup dictionary
            var appsByPath = [String: AppInfo]()
            for app in apps {
                appsByPath[app.path] = app
            }
            
            var orderedApps: [AppInfo] = []
            var usedPaths = Set<String>()
            
            // Add apps in saved order
            for savedApp in savedOrder {
                if let app = appsByPath[savedApp.appPath] {
                    orderedApps.append(app)
                    usedPaths.insert(savedApp.appPath)
                }
            }
            
            // Add new apps that weren't in saved order
            for app in apps {
                if !usedPaths.contains(app.path) {
                    orderedApps.append(app)
                }
            }
            
            print("App order loaded from Core Data with \(orderedApps.count) apps")
            return orderedApps
            
        } catch {
            print("Error loading app order: \(error)")
            return apps
        }
    }
    
    /// Clear all saved app orders
    func clearAppOrder() {
        let context = coreData.context
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = AppOrderEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            coreData.save()
            print("App order cleared from Core Data")
        } catch {
            print("Error clearing app order: \(error)")
        }
    }
}
