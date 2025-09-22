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
}
