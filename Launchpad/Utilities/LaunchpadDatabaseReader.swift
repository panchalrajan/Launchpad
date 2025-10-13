import Foundation
import SQLite3

@MainActor
final class LaunchpadDatabaseReader {
    
    /// Returns the path to the old macOS Launchpad database
    static func getOldLaunchpadDatabasePath() -> String? {
        // Get DARWIN_USER_DIR using getconf
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
                return dbPath
            }
        } catch {
            print("Failed to get DARWIN_USER_DIR: \(error)")
        }
        
        return nil
    }
    
    /// Checks if the old Launchpad database exists
    static func oldLaunchpadDatabaseExists() -> Bool {
        guard let dbPath = getOldLaunchpadDatabasePath() else { return false }
        return FileManager.default.fileExists(atPath: dbPath)
    }
    
    /// Reads the old Launchpad database and returns app layout information
    /// Returns a dictionary mapping app paths to their positions
    static func readOldLaunchpadLayout() -> [(path: String, page: Int, position: Int)]? {
        guard let dbPath = getOldLaunchpadDatabasePath() else {
            print("Could not determine old Launchpad database path")
            return nil
        }
        
        guard FileManager.default.fileExists(atPath: dbPath) else {
            print("Old Launchpad database does not exist at: \(dbPath)")
            return nil
        }
        
        var db: OpaquePointer?
        var results: [(path: String, page: Int, position: Int)] = []
        
        // Open database
        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            print("Failed to open database at: \(dbPath)")
            return nil
        }
        
        defer {
            sqlite3_close(db)
        }
        
        // Query to get apps with their positions
        // The Launchpad database has these main tables:
        // - apps: contains app information
        // - items: contains positioning information
        // - groups: contains folder/group information
        let query = """
            SELECT 
                apps.title,
                apps.path,
                items.parent_id,
                items.ordering,
                COALESCE(parent_items.parent_id, 0) as page_id
            FROM items
            INNER JOIN apps ON items.rowid = apps.item_id
            LEFT JOIN items as parent_items ON items.parent_id = parent_items.rowid
            WHERE items.parent_id IS NOT NULL
            ORDER BY page_id, items.parent_id, items.ordering
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
            print("Failed to prepare statement")
            return nil
        }
        
        defer {
            sqlite3_finalize(statement)
        }
        
        var currentPage = 0
        var lastParentId: Int64 = -1
        var positionInPage = 0
        
        // Execute query and process results
        while sqlite3_step(statement) == SQLITE_ROW {
            // Get path
            if let pathCString = sqlite3_column_text(statement, 1) {
                let path = String(cString: pathCString)
                
                // Get parent_id to track pages
                let parentId = sqlite3_column_int64(statement, 2)
                //let ordering = Int(sqlite3_column_int64(statement, 3))
                
                // Track page changes based on parent_id changes
                if lastParentId != -1 && lastParentId != parentId {
                    currentPage += 1
                    positionInPage = 0
                }
                lastParentId = parentId
                
                // Only include .app files
                if path.hasSuffix(".app") {
                    results.append((path: path, page: currentPage, position: positionInPage))
                    positionInPage += 1
                }
            }
        }
        
        print("Successfully read \(results.count) apps from old Launchpad database")
        return results
    }
    
    /// Reads folder structure from old Launchpad database
    static func readOldLaunchpadFolders() -> [(name: String, page: Int, appPaths: [String])]? {
        guard let dbPath = getOldLaunchpadDatabasePath() else {
            print("Could not determine old Launchpad database path")
            return nil
        }
        
        guard FileManager.default.fileExists(atPath: dbPath) else {
            print("Old Launchpad database does not exist at: \(dbPath)")
            return nil
        }
        
        var db: OpaquePointer?
        var folders: [(name: String, page: Int, appPaths: [String])] = []
        
        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            print("Failed to open database at: \(dbPath)")
            return nil
        }
        
        defer {
            sqlite3_close(db)
        }
        
        // Query to get folders with their apps
        let folderQuery = """
            SELECT 
                groups.title,
                folder_items.rowid as folder_id,
                folder_items.ordering
            FROM groups
            INNER JOIN items as folder_items ON groups.item_id = folder_items.rowid
            WHERE groups.title IS NOT NULL
            ORDER BY folder_items.ordering
        """
        
        var folderStmt: OpaquePointer?
        if sqlite3_prepare_v2(db, folderQuery, -1, &folderStmt, nil) != SQLITE_OK {
            print("Failed to prepare folder query")
            return nil
        }
        
        defer {
            sqlite3_finalize(folderStmt)
        }
        
        var folderIndex = 0
        while sqlite3_step(folderStmt) == SQLITE_ROW {
            if let nameCString = sqlite3_column_text(folderStmt, 0) {
                let folderName = String(cString: nameCString)
                let folderId = sqlite3_column_int64(folderStmt, 1)
                
                // Get apps in this folder
                let appsQuery = """
                    SELECT apps.path
                    FROM items
                    INNER JOIN apps ON items.rowid = apps.item_id
                    WHERE items.parent_id = ? AND apps.path IS NOT NULL
                    ORDER BY items.ordering
                """
                
                var appsStmt: OpaquePointer?
                if sqlite3_prepare_v2(db, appsQuery, -1, &appsStmt, nil) == SQLITE_OK {
                    sqlite3_bind_int64(appsStmt, 1, folderId)
                    
                    var appPaths: [String] = []
                    while sqlite3_step(appsStmt) == SQLITE_ROW {
                        if let pathCString = sqlite3_column_text(appsStmt, 0) {
                            let path = String(cString: pathCString)
                            if path.hasSuffix(".app") {
                                appPaths.append(path)
                            }
                        }
                    }
                    sqlite3_finalize(appsStmt)
                    
                    if !appPaths.isEmpty {
                        folders.append((name: folderName, page: folderIndex, appPaths: appPaths))
                    }
                }
                folderIndex += 1
            }
        }
        
        print("Successfully read \(folders.count) folders from old Launchpad database")
        return folders
    }
}
