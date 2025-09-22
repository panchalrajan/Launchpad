import AppKit
import Foundation

@MainActor
final class AppManager : ObservableObject {
  static let shared = AppManager()
    
    @Published var pages: [[AppGridItem]] {
        didSet {
            saveGridItems(items: pages.flatMap { $0 })
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

  private func saveGridItems(items: [AppGridItem]) {
    let itemsData = items.map { item -> [String: Any] in
      switch item {
      case .app(let app):
        return [
          "type": "app",
          "id": app.id.uuidString,
          "name": app.name,
          "path": app.path,
          "page": app.page,
        ]
      case .folder(let folder):
        let appsData = folder.apps.map { app in
          [
            "id": app.id.uuidString,
            "name": app.name,
            "path": app.path,
            "page": app.page,
          ]
        }
        return [
          "type": "folder",
          "id": folder.id.uuidString,
          "name": folder.name,
          "page": folder.page,
          "apps": appsData,
        ]
      }
    }

    userDefaults.set(itemsData, forKey: gridItemsKey)
    userDefaults.synchronize()
  }

  func clearGridItems(appsPerPage: Int) {
    userDefaults.removeObject(forKey: gridItemsKey)
    userDefaults.synchronize()
      loadGridItems(appsPerPage: appsPerPage)
  }

  private func discoverApps() -> [AppInfo] {
    let appPaths = ["/Applications", "/System/Applications"]
    var foundApps: [AppInfo] = []

    for basePath in appPaths {
      foundApps.append(contentsOf: discoverAppsRecursively(in: basePath))
    }

    return foundApps.sorted { $0.name.lowercased() < $1.name.lowercased() }
  }

  private func discoverAppsRecursively(
    in directory: String, maxDepth: Int = 3, currentDepth: Int = 0
  ) -> [AppInfo] {
    guard currentDepth < maxDepth,
      let contents = try? FileManager.default.contentsOfDirectory(atPath: directory)
    else { return [] }

    var foundApps: [AppInfo] = []

    for item in contents {
      let fullPath = "\(directory)/\(item)"

      if item.hasSuffix(".app") {
        let fallbackName = item.replacingOccurrences(of: ".app", with: "")
        let appName = getLocalizedAppName(
          for: URL(fileURLWithPath: fullPath), fallbackName: fallbackName)
        let icon = NSWorkspace.shared.icon(forFile: fullPath)
        icon.size = NSSize(width: 64, height: 64)
        foundApps.append(AppInfo(name: appName, icon: icon, path: fullPath))
      } else if shouldSearchDirectory(item: item, at: fullPath) {
        foundApps.append(
          contentsOf: discoverAppsRecursively(
            in: fullPath, maxDepth: maxDepth, currentDepth: currentDepth + 1
          ))
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
    let savedData = userDefaults.array(forKey: gridItemsKey) as? [[String: Any]]

    if savedData == nil {
      return apps.map { .app($0) }
    }

    let appsByPath = Dictionary(uniqueKeysWithValues: apps.map { ($0.path, $0) })
    var gridItems: [AppGridItem] = []
    var usedPaths = Set<String>()

    for itemData in savedData! {
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
      let appWithPage = AppInfo(name: app.name, icon: app.icon, path: app.path)
      gridItems.append(.app(appWithPage))
    }

    return gridItems
  }

  private func loadAppItem(from itemData: [String: Any], appsByPath: [String: AppInfo])
    -> AppGridItem?
  {
    guard let path = itemData["path"] as? String,
      let baseApp = appsByPath[path]
    else { return nil }

    let savedPage = itemData["page"] as? Int ?? 0
    let appWithPage = AppInfo(
      name: baseApp.name, icon: baseApp.icon, path: baseApp.path, page: savedPage)
    return .app(appWithPage)
  }

  private func loadFolderItem(from itemData: [String: Any], appsByPath: [String: AppInfo])
    -> AppGridItem?
  {
    guard let folderName = itemData["name"] as? String,
      let appsData = itemData["apps"] as? [[String: Any]]
    else { return nil }

    let folderApps = appsData.compactMap { appData -> AppInfo? in
      guard let path = appData["path"] as? String,
        let baseApp = appsByPath[path]
      else { return nil }

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

    let groupedByPage = Dictionary(grouping: items) { $0.page }
    let sortedPages = groupedByPage.keys.sorted()

    var pages: [[AppGridItem]] = []
    var currentPage = 0
    var itemsOnCurrentPage = 0
    var currentPageItems: [AppGridItem] = []

    for pageNum in sortedPages {
      let pageItems = groupedByPage[pageNum] ?? []

      for item in pageItems {
        if itemsOnCurrentPage >= appsPerPage {
          pages.append(currentPageItems)
          currentPage += 1
          currentPageItems = []
          itemsOnCurrentPage = 0
        }

        let updatedItem = item.page != currentPage ? updateItemPage(item, to: currentPage) : item
        currentPageItems.append(updatedItem)
        itemsOnCurrentPage += 1
      }
    }

    if !currentPageItems.isEmpty {
      pages.append(currentPageItems)
    }

    return pages.isEmpty ? [[]] : pages
  }

  private func updateItemPage(_ item: AppGridItem, to page: Int) -> AppGridItem {
    switch item {
    case .app(let app):
      return .app(AppInfo(name: app.name, icon: app.icon, path: app.path, page: page))
    case .folder(let folder):
      return .folder(Folder(name: folder.name, page: page, apps: folder.apps))
    }
  }

  private func getLocalizedAppName(for url: URL, fallbackName: String) -> String {
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
