import SwiftUI

extension AppGridItem {
   var path: String {
      switch self {
      case .app(let app): return app.path
      case .folder: return ""
      }
   }

   var appPaths: Set<String> {
      switch self {
      case .app(let app): return [app.path]
      case .folder(let folder): return Set(folder.apps.map(\.path))
      }
   }

   func serialize() -> [String: Any] {
      switch self {
      case .app(let app):
         return serialize(app)
      case .folder(let folder):
         return serialize(folder)
      }
   }

   func serialize(_ folder: Folder) -> [String : Any] {
      return [
         "type": "folder",
         "id": folder.id.uuidString,
         "name": folder.name,
         "page": folder.page,
         "apps": folder.apps.map(serialize)
      ]
   }

   func serialize(_ app: AppInfo) -> [String: Any] {
      [
         "type": "app",
         "id": app.id.uuidString,
         "name": app.name,
         "page": app.page,
         "path": app.path
      ]
   }
   
   func withUpdatedPage(_ newPage: Int) -> AppGridItem {
      switch self {
      case .app(let app):
         return .app(AppInfo(name: app.name, icon: app.icon, path: app.path, bundleId: app.bundleId, page: newPage))
      case .folder(let folder):
         return .folder(Folder(name: folder.name, page: newPage, apps: folder.apps))
      }
   }
}
