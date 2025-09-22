import SwiftUI

enum AppGridItem: Identifiable, Equatable {
  case app(AppInfo)
  case folder(Folder)

  var id: UUID {
    switch self {
    case .app(let app):
      return app.id
    case .folder(let folder):
      return folder.id
    }
  }

  var page: Int {
    switch self {
    case .app(let app):
      return app.page
    case .folder(let folder):
      return folder.page
    }
  }

  var name: String {
    switch self {
    case .app(let app):
      return app.name
    case .folder(let folder):
      return folder.name
    }
  }

  var isFolder: Bool {
    switch self {
    case .app:
      return false
    case .folder:
      return true
    }
  }

  var appInfo: AppInfo? {
    switch self {
    case .app(let app):
      return app
    case .folder:
      return nil
    }
  }

  var folder: Folder? {
    switch self {
    case .app:
      return nil
    case .folder(let folder):
      return folder
    }
  }

  static func == (lhs: AppGridItem, rhs: AppGridItem) -> Bool {
    lhs.id == rhs.id
  }
}
