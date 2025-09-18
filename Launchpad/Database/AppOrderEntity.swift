import CoreData
import Foundation

@objc(AppOrderEntity)
class AppOrderEntity: NSManagedObject {
    @NSManaged var appPath: String
    @NSManaged var orderIndex: Int32
    @NSManaged var dateModified: Date
}

extension AppOrderEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AppOrderEntity> {
        return NSFetchRequest<AppOrderEntity>(entityName: "AppOrderEntity")
    }
}
