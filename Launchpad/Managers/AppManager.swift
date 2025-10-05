import AppKit
import Foundation

@MainActor
final class AppManager: ObservableObject {
   private let userDefaults = UserDefaults.standard
   private let gridItemsKey = "LaunchpadGridItems"

   static let shared = AppManager()

   private init() {
      self.pages = [[]]
   }

   @Published var pages: [[AppGridItem]] {
      didSet { saveGridItems() }
   }

   func loadGridItems(appsPerPage: Int) {
      print("Load grid items.")
      let apps = discoverApps()
      let gridItems = loadLayoutFromUserDefaults(for: apps)
      pages = groupItemsByPage(items: gridItems, appsPerPage: appsPerPage)
   }

   private func saveGridItems() {
      print("Save grid items.")
      let itemsData = pages.flatMap { $0 }.map { $0.serialize() }
      userDefaults.set(itemsData, forKey: gridItemsKey)
   }

   func importLayout(appsPerPage: Int) {
      let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("LaunchpadLayout.json")
      importLayoutFromJSON(filePath: filePath, appsPerPage: appsPerPage)
   }

   func exportLayout() {
      let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("LaunchpadLayout.json")
      exportLayoutToJSON(filePath: filePath)
   }

   func clearGridItems(appsPerPage: Int) {
      print("Clear grid items.")
      userDefaults.removeObject(forKey: gridItemsKey)
      userDefaults.synchronize()
      loadGridItems(appsPerPage: appsPerPage)
   }

   func recalculatePages(appsPerPage: Int) {
      print("Recalculate pages.")
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
            let icon = NSWorkspace.shared.icon(forFile: fullPath).flattenedForConsistency()
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
      print("Load layout.")
      guard let savedData = userDefaults.array(forKey: gridItemsKey) as? [[String: Any]] else { return apps.map{.app($0)} }

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
      let path = itemData["path"] as! String
      let page = itemData["page"] as! Int
      let baseApp = appsByPath[path]
      if baseApp == nil {  return nil  }
      return .app(AppInfo(name: baseApp!.name, icon: baseApp!.icon, path: baseApp!.path, page: page))

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

   private func groupItemsByPage(items: [AppGridItem], appsPerPage: Int) -> [[AppGridItem]] {
      print("App count: \(items.count)")
      let groupedByPage = Dictionary(grouping: items) { $0.page }
      let pageCount = max(groupedByPage.keys.max() ?? 1, 1)
      var pages: [[AppGridItem]] = []
      var currentPage = 0

      print("Page count: \(pageCount)")

      for pageNum in currentPage...pageCount {
         currentPage = pageNum
         var currentPageItems: [AppGridItem] = []
         let pageItems = groupedByPage[pageNum] ?? []
         print("Current page: \(currentPage), page num: \(pageNum), items: \(pageItems.count)")
         for item in pageItems {
            if currentPageItems.count >= appsPerPage {
               pages.append(currentPageItems)
               currentPage += 1
               currentPageItems = []
            }

            let updatedItem = currentPage > item.page ? updateItemPage(item: item, to: currentPage) : item
            currentPageItems.append(updatedItem)
         }

         if !currentPageItems.isEmpty {
            pages.append(currentPageItems)
         }
      }
      return pages.isEmpty ? [[]] : pages
   }

   private func updateItemPage(item: AppGridItem, to page: Int) -> AppGridItem {
      return item.withUpdatedPage(page)
   }

   private func importLayoutFromJSON(filePath: URL, appsPerPage: Int) {
      do {
         let jsonData = try Data(contentsOf: filePath)
         let itemsArray = try JSONSerialization.jsonObject(with: jsonData) as! [[String: Any]]
         let allApps = discoverApps()
         let appsByPath = Dictionary(uniqueKeysWithValues: allApps.map { ($0.path, $0) })
         var gridItems: [AppGridItem] = []
         for itemData in itemsArray {
            let type = itemData["type"] as! String
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
         print("Import finished successfully from: \(filePath.path)")
      } catch {
         print("Failed to import layout: \(error)")
      }
   }

   private func exportLayoutToJSON(filePath: URL) {
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
