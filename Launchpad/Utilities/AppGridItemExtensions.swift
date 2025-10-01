import SwiftUI

extension AppGridItem {
  var path: String {
    switch self {
    case .app(let app): 
      return app.path
    case .folder: 
      return ""
    }
  }

  var appPaths: Set<String> {
    switch self {
    case .app(let app): 
      return Set([app.path])
    case .folder(let folder): 
      return Set(folder.apps.map(\.path))
    }
  }
  
  var displayName: String {
    switch self {
    case .app(let app):
      return app.name
    case .folder(let folder):
      return folder.name
    }
  }
  
  func withUpdatedPage(_ newPage: Int) -> AppGridItem {
    switch self {
    case .app(let app):
      return .app(AppInfo(name: app.name, icon: app.icon, path: app.path, page: newPage))
    case .folder(let folder):
      return .folder(Folder(name: folder.name, page: newPage, apps: folder.apps))
    }
  }
}
