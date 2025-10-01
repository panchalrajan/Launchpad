import AppKit
import Foundation

@MainActor
final class AppManager: ObservableObject {
   static let shared = AppManager()

   @Published var pages: [[AppGridItem]] {
      didSet {
         Task { await saveGridItems() }
      }
   }

   private let userDefaults = UserDefaults.standard
   private let gridItemsKey = "LaunchpadGridItems"

   private init() {
      self.pages = [[]]
   }

   func loadGridItems(appsPerPage: Int) {
      let apps = discoverApps()
      let gridItems = loadLayoutFromUserDefaults(for: apps)
      pages = groupItemsByPage(items: gridItems, appsPerPage: appsPerPage)
   }

   func importLayout(appsPerPage: Int) {
      let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("LaunchpadLayout.json")
      importLayoutFromJSON(filePath: filePath, appsPerPage: appsPerPage)
   }

   func exportLayout() {
      let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("LaunchpadLayout.json")
      exportLayoutToJSON(filePath: filePath)
   }

   private func saveGridItems() async {
      print("Save grid items.")
      var itemsWithCorrectPages: [AppGridItem] = []
      
      // Assign correct page numbers based on actual page index
      for (pageIndex, pageItems) in pages.enumerated() {
         for item in pageItems {
            let correctedItem: AppGridItem
            switch item {
            case .app(let app):
               correctedItem = .app(AppInfo(name: app.name, icon: app.icon, path: app.path, page: pageIndex))
            case .folder(let folder):
               correctedItem = .folder(Folder(name: folder.name, page: pageIndex, apps: folder.apps))
            }
            itemsWithCorrectPages.append(correctedItem)
         }
      }
      
      let itemsData = itemsWithCorrectPages.map { $0.serialize() }
      userDefaults.set(itemsData, forKey: gridItemsKey)
   }

   func clearGridItems(appsPerPage: Int) {
      userDefaults.removeObject(forKey: gridItemsKey)
      userDefaults.synchronize()
      loadGridItems(appsPerPage: appsPerPage)
   }

   func recalculatePages(appsPerPage: Int) {
      let allItems = pages.flatMap { $0 }
      pages = groupItemsByPage(items: allItems, appsPerPage: appsPerPage)
   }

   private func discoverApps() -> [AppInfo] {
      print("Discover apps.")
      let appPaths = ["/Applications", "/System/Applications"]
      return appPaths.flatMap { discoverAppsRecursively(directory: $0) }.sorted { $0.name.lowercased() < $1.name.lowercased() }
   }

   private func discoverAppsRecursively(directory: String, maxDepth: Int = 3, currentDepth: Int = 0) -> [AppInfo] {
      guard currentDepth < maxDepth, let contents = try? FileManager.default.contentsOfDirectory(atPath: directory)
      else { return [] }

      var foundApps: [AppInfo] = []
      for item in contents {
         let fullPath = "\(directory)/\(item)"
         if item.hasSuffix(".app") {
            let fallbackName = item.replacingOccurrences(of: ".app", with: "")
            let appName = getLocalizedAppName(for: URL(fileURLWithPath: fullPath), fallbackName: fallbackName)
            let icon = NSWorkspace.shared.icon(forFile: fullPath).flattenedForConsistency(targetPixelSize: 256)
            foundApps.append(AppInfo(name: appName, icon: icon, path: fullPath))
         } else if shouldSearchDirectory(item: item, at: fullPath) {
            foundApps.append(contentsOf: discoverAppsRecursively(directory: fullPath, maxDepth: maxDepth, currentDepth: currentDepth + 1))
         }
      }
      return foundApps
   }

   private func shouldSearchDirectory(item: String, at path: String) -> Bool {
      let skipDirectories = [".Trash", ".DS_Store", ".localized"]
      var isDirectory: ObjCBool = false
      return FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
      && isDirectory.boolValue && !skipDirectories.contains(item) && !item.hasPrefix(".")
   }

   private func loadLayoutFromUserDefaults(for apps: [AppInfo]) -> [AppGridItem] {
      guard let savedData = userDefaults.array(forKey: gridItemsKey) as? [[String: Any]] else {
         return apps.map { .app($0) }
      }

      let appsByPath = Dictionary(uniqueKeysWithValues: apps.map { ($0.path, $0) })
      var gridItems: [AppGridItem] = []
      var usedPaths = Set<String>()

      for itemData in savedData {
         guard let type = itemData["type"] as? String else { continue }
         switch type {
         case "app":
            if let gridItem = loadAppItem(from: itemData, appsByPath: appsByPath) {
               gridItems.append(gridItem)
               usedPaths.insert(gridItem.path)
            }
         case "folder":
            if let gridItem = loadFolderItem(from: itemData, appsByPath: appsByPath) {
               gridItems.append(gridItem)
               usedPaths.formUnion(gridItem.appPaths)
            }
         default:
            break
         }
      }

      for app in apps where !usedPaths.contains(app.path) {
         gridItems.append(.app(app))
      }

      return gridItems
   }

   private func loadAppItem(from itemData: [String: Any], appsByPath: [String: AppInfo]) -> AppGridItem? {
      guard let path = itemData["path"] as? String,
            let baseApp = appsByPath[path] else { return nil }
      let savedPage = itemData["page"] as? Int ?? 0
      let appWithPage = AppInfo(name: baseApp.name, icon: baseApp.icon, path: baseApp.path, page: savedPage)
      return .app(appWithPage)
   }

   private func loadFolderItem(from itemData: [String: Any], appsByPath: [String: AppInfo]) -> AppGridItem? {
      guard let folderName = itemData["name"] as? String,
            let appsData = itemData["apps"] as? [[String: Any]] else { return nil }
      let folderApps = appsData.compactMap { appData -> AppInfo? in
         guard let path = appData["path"] as? String,
               let baseApp = appsByPath[path] else { return nil }
         let savedPage = appData["page"] as? Int ?? 0
         return AppInfo(name: baseApp.name, icon: baseApp.icon, path: baseApp.path, page: savedPage)
      }
      guard !folderApps.isEmpty else { return nil }
      let savedPage = itemData["page"] as? Int ?? 0
      let folder = Folder(name: folderName, page: savedPage, apps: folderApps)
      return .folder(folder)
   }

   private func groupItemsByPage(items: [AppGridItem], appsPerPage: Int) -> [[AppGridItem]] {
      guard !items.isEmpty else { return [[]] }
      print("Group items: \(items)")
      let groupedByPage = Dictionary(grouping: items) { $0.page }
      let sortedPages = groupedByPage.keys.sorted()
      print("Grouped by page: \(sortedPages.count)")
      var pages: [[AppGridItem]] = []
      var currentPage = 0
      var itemsOnCurrentPage = 0
      var currentPageItems: [AppGridItem] = []
      for pageNum in sortedPages {
         let pageItems = groupedByPage[pageNum] ?? []
         print("Page items: \(pageItems.count)")
         for item in pageItems {
            if itemsOnCurrentPage >= appsPerPage {
               pages.append(currentPageItems)
               currentPage += 1
               currentPageItems = []
               itemsOnCurrentPage = 0
            }
            let updatedItem = item.page != currentPage ? updateItemPage(item: item, to: currentPage) : item
            currentPageItems.append(updatedItem)
            itemsOnCurrentPage += 1
         }
      }
      if !currentPageItems.isEmpty {
         pages.append(currentPageItems)
      }
      return pages.isEmpty ? [[]] : pages
   }

   private func updateItemPage(item: AppGridItem, to page: Int) -> AppGridItem {
      print("Update item page. Old page: \(item.page), New page: \(page)")
      switch item {
      case .app(let app):
         return .app(AppInfo(name: app.name, icon: app.icon, path: app.path, page: page))
      case .folder(let folder):
         return .folder(Folder(name: folder.name, page: page, apps: folder.apps))
      }
   }

   private func getLocalizedAppName(for url: URL, fallbackName: String) -> String {
      if let rawValue = NSMetadataItem(url: url)?.value(forAttribute: kMDItemDisplayName as String) as? String {
         var trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
         if trimmed.lowercased().hasSuffix(".app") {
            trimmed = String(trimmed.dropLast(4))
         }
         return trimmed
      }
      return fallbackName
   }

   private func importLayoutFromJSON(filePath: URL, appsPerPage: Int) {
      do {
         let jsonData = try Data(contentsOf: filePath)
         guard let itemsArray = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] else {
            print("Invalid JSON format")
            return
         }
         let allApps = discoverApps()
         let appsByPath = Dictionary(uniqueKeysWithValues: allApps.map { ($0.path, $0) })
         var gridItems: [AppGridItem] = []
         for itemData in itemsArray {
            guard let type = itemData["type"] as? String else { continue }
            switch type {
            case "app":
               if let gridItem = loadAppItem(from: itemData, appsByPath: appsByPath) {
                  gridItems.append(gridItem)
               }
            case "folder":
               if let gridItem = loadFolderItem(from: itemData, appsByPath: appsByPath) {
                  gridItems.append(gridItem)
               }
            default:
               break
            }
         }
         let newPages = groupItemsByPage(items: gridItems, appsPerPage: appsPerPage)
         self.pages = newPages
         print("Imported layout from: \(filePath.path)")
      } catch {
         print("Failed to import layout: \(error)")
      }
   }

   private func exportLayoutToJSON(filePath: URL,) {
      do {
         let itemsData = pages.flatMap { $0 }.map { $0.serialize() }
         let jsonData = try JSONSerialization.data(withJSONObject: itemsData, options: .prettyPrinted)
         try jsonData.write(to: filePath)
         print("Export finished successfully to \(filePath.path)!")
      } catch {
         print("Failed to export layout: \(error)")
      }
   }
}
