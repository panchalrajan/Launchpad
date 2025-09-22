import Foundation
import AppKit
import SQLite3

@MainActor
final class NativeLaunchpadImporter {

    init() {}

    // Public entry point: imports and updates AppManager pages
     func importFromNativeLaunchpad() throws -> ImportResult {
        let dbPath = try getNativeLaunchpadDatabasePath()

        guard FileManager.default.fileExists(atPath: dbPath) else {
            throw ImportError.databaseNotFound("Native Launchpad database not found at \(dbPath)")
        }

        let data = try parseLaunchpadDatabase(at: dbPath)

        let result = try convertToPagesAndApply(launchpadData: data)

        return result
    }

    // MARK: - Native DB path

    private func getNativeLaunchpadDatabasePath() throws -> String {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/getconf")
        task.arguments = ["DARWIN_USER_DIR"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        try task.run()
        task.waitUntilExit()

        guard task.terminationStatus == 0 else {
            throw ImportError.systemError("Failed to get user directory path")
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let userDir = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        // Native Launchpad DB
        return "/private\(userDir)com.apple.dock.launchpad/db/db"
    }

    // MARK: - Parse Z_* schema

    private func parseLaunchpadDatabase(at dbPath: String) throws -> LaunchpadData {
        var db: OpaquePointer?
        guard sqlite3_open_v2(dbPath, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK else {
            throw ImportError.databaseError("Failed to open native Launchpad database")
        }
        defer { sqlite3_close(db) }

        logAllTables(in: db)

        // We only support modern Z_* schema
        guard tableExists(in: db, name: "ZAPP"),
              tableExists(in: db, name: "ZGROUP"),
              tableExists(in: db, name: "ZITEM")
        else {
            throw ImportError.databaseError("Unsupported Launchpad database schema (ZAPP/ZGROUP/ZITEM not found)")
        }

        // ZAPP
        var apps: [String: LaunchpadDBApp] = [:]
        let appQuery = "SELECT Z_PK, ZTITLE, ZBUNDLEID FROM ZAPP"
        var appStmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, appQuery, -1, &appStmt, nil) == SQLITE_OK else {
            throw ImportError.databaseError("Failed to query ZAPP table")
        }
        defer { sqlite3_finalize(appStmt) }
        while sqlite3_step(appStmt) == SQLITE_ROW {
            let pk = String(sqlite3_column_int(appStmt, 0))
            let title = sqlite3_column_text(appStmt, 1) != nil ? String(cString: sqlite3_column_text(appStmt, 1)) : "Unknown App"
            let bundleId = sqlite3_column_text(appStmt, 2) != nil ? String(cString: sqlite3_column_text(appStmt, 2)) : ""
            apps[pk] = LaunchpadDBApp(itemId: pk, title: title, bundleId: bundleId)
        }

        // ZGROUP
        var groups: [String: LaunchpadGroup] = [:]
        let groupQuery = "SELECT Z_PK, ZTITLE FROM ZGROUP"
        var groupStmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, groupQuery, -1, &groupStmt, nil) == SQLITE_OK else {
            throw ImportError.databaseError("Failed to query ZGROUP table")
        }
        defer { sqlite3_finalize(groupStmt) }
        while sqlite3_step(groupStmt) == SQLITE_ROW {
            let pk = String(sqlite3_column_int(groupStmt, 0))
            let title = sqlite3_column_text(groupStmt, 1) != nil ? String(cString: sqlite3_column_text(groupStmt, 1)).trimmingCharacters(in: .whitespacesAndNewlines) : "Untitled"
            groups[pk] = LaunchpadGroup(itemId: pk, title: title.isEmpty ? "Untitled" : title)
        }

        // ZITEM
        var items: [LaunchpadDBItem] = []
        let itemQuery = "SELECT Z_PK, ZTYPE, ZPARENT, ZORDER FROM ZITEM ORDER BY ZPARENT, ZORDER"
        var itemStmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, itemQuery, -1, &itemStmt, nil) == SQLITE_OK else {
            throw ImportError.databaseError("Failed to query ZITEM table")
        }
        defer { sqlite3_finalize(itemStmt) }
        while sqlite3_step(itemStmt) == SQLITE_ROW {
            let pk = String(sqlite3_column_int(itemStmt, 0))
            let type = sqlite3_column_int(itemStmt, 1)
            let parent = sqlite3_column_int(itemStmt, 2)
            let order = sqlite3_column_int(itemStmt, 3)
            items.append(LaunchpadDBItem(rowId: pk, type: Int(type), parentId: Int(parent), ordering: Int(order)))
        }

        print("📱 Found \(apps.count) apps (ZAPP)")
        print("📁 Found \(groups.count) folders (ZGROUP)")
        print("🗂 Found \(items.count) layout items (ZITEM)")

        return LaunchpadData(apps: apps, groups: groups, items: items)
    }

    private func logAllTables(in db: OpaquePointer?) {
        let query = "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            var names: [String] = []
            defer { sqlite3_finalize(stmt) }
            while sqlite3_step(stmt) == SQLITE_ROW {
                if let cName = sqlite3_column_text(stmt, 0) {
                    names.append(String(cString: cName))
                }
            }
            print("🧩 Tables in native DB: \(names.joined(separator: ", "))")
        }
    }

    private func tableExists(in db: OpaquePointer?, name: String) -> Bool {
        let query = "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name = ?;"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK else { return false }
        defer { sqlite3_finalize(stmt) }
        name.withCString { cstr in
            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            _ = sqlite3_bind_text(stmt, 1, cstr, -1, SQLITE_TRANSIENT)
        }
        if sqlite3_step(stmt) == SQLITE_ROW {
            let count = sqlite3_column_int(stmt, 0)
            return count > 0
        }
        return false
    }

    // MARK: - Convert to AppGridItem pages

    @MainActor private func convertToPagesAndApply(launchpadData: LaunchpadData) throws -> ImportResult {
        // Build parent -> children index
        var childrenByParent: [Int: [LaunchpadDBItem]] = [:]
        for item in launchpadData.items { childrenByParent[item.parentId, default: []].append(item) }
        for key in childrenByParent.keys { childrenByParent[key]?.sort { $0.ordering < $1.ordering } }

        // Top-level containers: parent_id = 1, type = 3
        let topContainers = launchpadData.items
            .filter { $0.type == 3 && $0.parentId == 1 }
            .sorted { $0.ordering < $1.ordering }

        #if DEBUG
        print("🧭 Top containers: \(topContainers.map{ $0.rowId }.joined(separator: ", "))")
        #endif

        var pages: [[AppGridItem]] = []
        var convertedApps = 0
        var convertedFolders = 0
        var failedApps: [String] = []

        for (pageIndex, container) in topContainers.enumerated() {
            var pageItems: [AppGridItem] = []

            let containerId = intValue(container.rowId)
            let directChildren = (childrenByParent[containerId] ?? [])
            let directApps = directChildren.filter { $0.type == 4 }
            let folderPages = directChildren.filter { $0.type == 2 }

            // Place direct apps based on ordering
            for appItem in directApps {
                if let app = launchpadData.apps[appItem.rowId],
                   let appInfo = findLocalApp(bundleId: app.bundleId, title: app.title) {
                    let uiApp = AppInfo(name: appInfo.name, icon: appInfo.icon, path: appInfo.path, page: pageIndex)
                    pageItems.append(.app(uiApp))
                    convertedApps += 1
                } else {
                    failedApps.append(launchpadData.apps[appItem.rowId]?.title ?? appItem.rowId)
                }
            }

            // Place folders — each folder is represented by one or more ZITEM.type=2 pages under this container
            // We create one folder per folder-page ordering, aggregating child apps from the folder slot containers (type=3)
            for page in folderPages {
                let pageId = intValue(page.rowId)
                let slotContainers = (childrenByParent[pageId] ?? []).filter { $0.type == 3 }

                // Collect apps in folder
                var folderApps: [AppInfo] = []
                for slot in slotContainers {
                    let slotId = intValue(slot.rowId)
                    let appChildren = (childrenByParent[slotId] ?? []).filter { $0.type == 4 }
                    for child in appChildren {
                        if let app = launchpadData.apps[child.rowId],
                           let info = findLocalApp(bundleId: app.bundleId, title: app.title) {
                            let uiApp = AppInfo(name: info.name, icon: info.icon, path: info.path, page: pageIndex)
                            folderApps.append(uiApp)
                        } else {
                            failedApps.append(launchpadData.apps[child.rowId]?.title ?? child.rowId)
                        }
                    }
                }

                // Folder name: use ZGROUP title if meaningful, else compose from top app names
                let rawTitle = (launchpadData.groups[page.rowId]?.title ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                let finalName: String
                if isPlaceholderFolderTitle(rawTitle) {
                    finalName = computeFolderName(from: folderApps)
                } else {
                    finalName = rawTitle
                }

                let folder = Folder(name: finalName, page: pageIndex, apps: folderApps)
                pageItems.append(.folder(folder))
                convertedFolders += 1
            }

            // Sort page items by their original ordering within the container
            // Combine both directApps and folderPages respecting their 'ordering'
            let orderingMap: [UUID: Int] = {
                var map: [UUID: Int] = [:]
                // direct apps
                for appItem in directApps {
                    if let app = launchpadData.apps[appItem.rowId],
                       let local = findLocalApp(bundleId: app.bundleId, title: app.title) {
                        // find the matching element we appended
                        if let idx = pageItems.firstIndex(where: {
                            if case .app(let a) = $0 { return a.path == local.path }
                            return false
                        }) {
                            map[pageItems[idx].id] = appItem.ordering
                        }
                    }
                }
                // folders (use folder page ordering)
                for folderItem in folderPages {
                    // We appended one folder per folderItem in the same sequence, so locate by name + page
                    let rawTitle = (launchpadData.groups[folderItem.rowId]?.title ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                    let desiredName = isPlaceholderFolderTitle(rawTitle) ? nil : rawTitle
                    // find first folder without an assigned ordering yet
                    if let idx = pageItems.firstIndex(where: {
                        if case .folder(let f) = $0 {
                            if let dn = desiredName {
                                return f.page == pageIndex && f.name == dn && map[$0.id] == nil
                            } else {
                                return f.page == pageIndex && map[$0.id] == nil
                            }
                        }
                        return false
                    }) {
                        map[pageItems[idx].id] = folderItem.ordering
                    }
                }
                return map
            }()

            pageItems.sort { (lhs, rhs) -> Bool in
                let lo = orderingMap[lhs.id] ?? Int.max
                let ro = orderingMap[rhs.id] ?? Int.max
                if lo != ro { return lo < ro }
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }

            pages.append(pageItems)
        }

        // Apply to app
        AppManager.shared.pages = pages

        print("✅ Import finished: \(convertedApps) apps, \(convertedFolders) folders")
        if !failedApps.isEmpty { print("⚠️ \(failedApps.count) apps not found: \(failedApps.prefix(5).joined(separator: ", "))") }

        return ImportResult(convertedApps: convertedApps, convertedFolders: convertedFolders, failedApps: failedApps)
    }

    // MARK: - Helpers

    private func intValue(_ s: String) -> Int { Int(s) ?? 0 }

    private func computeFolderName(from apps: [AppInfo]) -> String {
        let names = apps.prefix(3).map { $0.name }
        switch names.count {
        case 0: return "Untitled"
        case 1: return names[0]
        case 2: return names[0] + " + " + names[1]
        default: return names[0] + " + " + names[1] + " + …"
        }
    }

    private func isPlaceholderFolderTitle(_ s: String) -> Bool {
        if s.isEmpty { return true }
        let lower = s.lowercased()
        let placeholders: Set<String> = [
            "untitled",
            "untitled folder",
            "folder",
            "new folder",
            "未命名",
            "未命名文件夹"
        ]
        return placeholders.contains(lower)
    }

    // Resolve an app path from bundle id and title
    private func findLocalApp(bundleId: String, title: String) -> AppInfo? {
        // Try bundle id via NSWorkspace
        if let appPath = NSWorkspace.shared.absolutePathForApplication(withBundleIdentifier: bundleId) {
            let url = URL(fileURLWithPath: appPath)
            return appInfo(from: url, preferredName: title)
        }

        // Fallback: common directories
        let searchPaths = [
            "/Applications",
            "/System/Applications",
            "/System/Applications/Utilities",
            "/Applications/Utilities"
        ]

        for searchPath in searchPaths {
            if let app = searchAppInDirectory(searchPath, bundleId: bundleId, title: title) {
                return app
            }
        }

        return nil
    }

    private func searchAppInDirectory(_ path: String, bundleId: String, title: String) -> AppInfo? {
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(at: URL(fileURLWithPath: path),
                                                      includingPropertiesForKeys: nil,
                                                      options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]) else {
            return nil
        }

        for case let url as URL in enumerator {
            if url.pathExtension == "app" {
                if let bundle = Bundle(url: url) {
                    if bundle.bundleIdentifier == bundleId {
                        return appInfo(from: url, preferredName: title)
                    }
                    if let appName = bundle.infoDictionary?["CFBundleName"] as? String,
                       appName == title {
                        return appInfo(from: url, preferredName: title)
                    }
                }
            }
        }

        return nil
    }

    // Build AppInfo from URL with localized display name and icon
    private func appInfo(from url: URL, preferredName: String) -> AppInfo? {
        let path = url.path
        let fallbackName = url.deletingPathExtension().lastPathComponent
        let displayName = localizedAppName(for: url, fallbackName: preferredName.isEmpty ? fallbackName : preferredName)
        let icon = NSWorkspace.shared.icon(forFile: path)
        icon.size = NSSize(width: 64, height: 64)
        return AppInfo(name: displayName, icon: icon, path: path)
    }

    private func localizedAppName(for url: URL, fallbackName: String) -> String {
        var resolvedName: String?

        func consider(_ rawValue: String?) {
            guard let rawValue = rawValue else { return }
            var trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.lowercased().hasSuffix(".app") {
                trimmed = String(trimmed.dropLast(4))
            }
            guard !trimmed.isEmpty, resolvedName == nil, trimmed != fallbackName else { return }
            resolvedName = trimmed
        }

        if let metadataItem = NSMetadataItem(url: url) {
            consider(metadataItem.value(forAttribute: kMDItemDisplayName as String) as? String)

            if let alternatesValue = metadataItem.value(forAttribute: "kMDItemAlternateNames") {
                if let names = alternatesValue as? [String] {
                    names.forEach { consider($0) }
                } else if let names = alternatesValue as? NSArray {
                    for case let name as String in names { consider(name) }
                }
            }
        }

        return resolvedName ?? fallbackName
    }
}

// MARK: - Data models used internally

struct LaunchpadData {
    let apps: [String: LaunchpadDBApp]
    let groups: [String: LaunchpadGroup]
    let items: [LaunchpadDBItem]
}

struct LaunchpadDBApp {
    let itemId: String
    let title: String
    let bundleId: String
}

struct LaunchpadGroup {
    let itemId: String
    let title: String
}

struct LaunchpadDBItem {
    let rowId: String
    let type: Int  // 1=root, 2=page, 3=container, 4=app
    let parentId: Int
    let ordering: Int
}

struct ImportResult {
    let convertedApps: Int
    let convertedFolders: Int
    let failedApps: [String]

    var summary: String {
        var lines = [
            "✅ Import Completed!",
            "📱 Apps: \(convertedApps)",
            "📁 Folders: \(convertedFolders)"
        ]

        if !failedApps.isEmpty {
            lines.append("⚠️ Not found: \(failedApps.count)")
        }

        return lines.joined(separator: "\n")
    }
}

enum ImportError: LocalizedError {
    case databaseNotFound(String)
    case databaseError(String)
    case systemError(String)
    case conversionError(String)

    var errorDescription: String? {
        switch self {
        case .databaseNotFound(let msg):
            return "Database not found: \(msg)"
        case .databaseError(let msg):
            return "Database error: \(msg)"
        case .systemError(let msg):
            return "System error: \(msg)"
        case .conversionError(let msg):
            return "Conversion error: \(msg)"
        }
    }
}
