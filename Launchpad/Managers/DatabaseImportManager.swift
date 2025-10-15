import Foundation
import SQLite3

@MainActor
final class DatabaseImportManager {
   static let shared = DatabaseImportManager()

   func oldLaunchpadDatabaseExists() -> Bool {
      guard let dbPath = getOldLaunchpadDatabasePath() else { return false }
      return FileManager.default.fileExists(atPath: dbPath)
   }

   func readOldLaunchpadLayout(currentApps: [AppInfo]) -> [AppGridItem] {
      guard let dbPath = getOldLaunchpadDatabasePath() else {
         return []
      }

      guard FileManager.default.fileExists(atPath: dbPath) else {
         print("Old Launchpad database does not exist at: \(dbPath)")
         return []
      }

      let appsByName = Dictionary(uniqueKeysWithValues: currentApps.map { ($0.name, $0) })

      var db: OpaquePointer?
      var results: [AppGridItem] = []

      // Open database
      if sqlite3_open(dbPath, &db) != SQLITE_OK {
         print("Failed to open database at: \(dbPath)")
         return []
      }

      defer {
         sqlite3_close(db)
      }

      do {
         let apps = try parseApps(from: db)
         let groups = try parseGroups(from: db)
         let items = try parseItems(from: db)

         print("[Importer] Parsed \(apps.count) apps, \(groups.count) groups, \(items.count) items")

         // Type: 1=root, 2=page, 3=folder, 4=app

         // Find root item
         guard let rootItem = items.first(where: { $0.type == 1 }) else {
            print("[Importer] No root item found in database")
            return []
         }

         print("[Importer] Root item found: rowId=\(rootItem.rowId)")

         // Find all pages (children of root)
         let pages = items
            .filter { $0.parentId == Int(rootItem.rowId)! }
            .sorted { $0.ordering < $1.ordering }

         print("[Importer] Found \(pages.count) pages")

         // Process each page
         for (pageIndex, page) in pages.enumerated() {
            // Find all items on this page
            let pageItems = items
               .filter { $0.parentId == Int(page.rowId)! }
               .sorted { $0.ordering < $1.ordering }

            print("[Importer] Page \(pageIndex): \(pageItems.count) items")

            // Process each item on the page
            for (position, item) in pageItems.enumerated() {
               // If it's an app, add it to results
               if item.type == 4, let app = apps[item.rowId] {
                  print("[Importer] App: \(app.bundleId) -> page=\(pageIndex), pos=\(position)")
                  let baseApp = appsByName[app.title]
                  if baseApp != nil {
                     results.append(.app(AppInfo(name: baseApp!.name, icon: baseApp!.icon, path: baseApp!.path, page: pageIndex)))
                  }
               }
               // If it's a folder (type 3), process apps inside it
               else {
                  let folderName = groups[item.rowId]?.title ?? "Unknown"
                  let folderPages = items.filter { $0.parentId == Int(item.rowId)! }

                  var folderItems : [AppInfo] = []

                  for folderPage in folderPages {
                     let folderApps = items
                        .filter { $0.parentId == Int(folderPage.rowId)! }
                        .sorted { $0.ordering < $1.ordering }

                     for folderApp in folderApps {
                        if let app = apps[folderApp.rowId] {
                           print("[Importer]   - \(app.bundleId)")
                           let baseApp = appsByName[app.title]
                           if baseApp != nil {
                              folderItems.append(AppInfo(name: baseApp!.name, icon: baseApp!.icon, path: baseApp!.path, page: pageIndex))
                           }
                        }
                     }
                  }
                  results.append(.folder(Folder(name: folderName, page: pageIndex, apps: folderItems)))
               }
            }
         }

         print("[Importer][Success] Successfully read \(results.count) apps from old Launchpad database")
         return results
      } catch {
         print("[Importer] Error parsing old Launchpad database: \(error)")
         return []
      }
   }

   private func getOldLaunchpadDatabasePath() -> String? {
      let task = Process()
      task.launchPath = "/usr/bin/getconf"
      task.arguments = ["DARWIN_USER_DIR"]

      let pipe = Pipe()
      task.standardOutput = pipe
      task.standardError = Pipe()

      do {
         try task.run()
         task.waitUntilExit()

         let data = pipe.fileHandleForReading.readDataToEndOfFile()
         if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
            let dbPath = "/private\(output)com.apple.dock.launchpad/db/db"
            print("Old Launchpad database path: " + dbPath)
            return dbPath
         }
      } catch {
         print("Could not determine old Launchpad database path")
      }

      return nil
   }

   private func parseApps(from db: OpaquePointer?) throws -> [String: LaunchpadDBApp] {
      var apps: [String: LaunchpadDBApp] = [:]
      let query = "SELECT item_id, title, bundleid, storeid FROM apps"
      var stmt: OpaquePointer?

      guard sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK else {
         throw ImportError.databaseError("Failed to query apps table")
      }
      defer { sqlite3_finalize(stmt) }

      while sqlite3_step(stmt) == SQLITE_ROW {
         let itemId = String(sqlite3_column_int(stmt, 0))
         let title = sqlite3_column_text(stmt, 1) != nil ? String(cString: sqlite3_column_text(stmt, 1)) : "Unknown App"
         let bundleId = sqlite3_column_text(stmt, 2) != nil ? String(cString: sqlite3_column_text(stmt, 2)): ""

         apps[itemId] = LaunchpadDBApp( itemId: itemId,  title: title,  bundleId: bundleId  )
      }

      return apps
   }

   private func parseGroups(from db: OpaquePointer?) throws -> [String: LaunchpadGroup] {
      var groups: [String: LaunchpadGroup] = [:]
      let query = "SELECT item_id, title FROM groups"
      var stmt: OpaquePointer?

      guard sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK else {
         throw ImportError.databaseError("Failed to query groups table")
      }
      defer { sqlite3_finalize(stmt) }

      while sqlite3_step(stmt) == SQLITE_ROW {
         let itemId = String(sqlite3_column_int(stmt, 0))
         let title = sqlite3_column_text(stmt, 1) != nil ? String(cString: sqlite3_column_text(stmt, 1)).trimmingCharacters(in: .whitespacesAndNewlines) : "Untitled"

         groups[itemId] = LaunchpadGroup(itemId: itemId,  title: title  )
      }
      
      return groups
   }

   private func parseItems(from db: OpaquePointer?) throws -> [LaunchpadDBItem] {
      var items: [LaunchpadDBItem] = []
      let query = "SELECT rowid, uuid, flags, type, parent_id, ordering FROM items ORDER BY parent_id, ordering"
      var stmt: OpaquePointer?

      guard sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK else {
         throw ImportError.databaseError("Failed to query items table")
      }
      defer { sqlite3_finalize(stmt) }

      while sqlite3_step(stmt) == SQLITE_ROW {
         let rowId = String(sqlite3_column_int(stmt, 0))
         let type = sqlite3_column_int(stmt, 3)
         let parentId = sqlite3_column_int(stmt, 4)
         let ordering = sqlite3_column_int(stmt, 5)

         items.append(LaunchpadDBItem(rowId: rowId, type: Int(type),  parentId: Int(parentId),   ordering: Int(ordering)))
      }

      return items
   }
}