import SwiftUI

struct Folder: Identifiable, Equatable {
  let id: UUID
  var name: String
  var page: Int
  var apps: [AppInfo]

  init(name: String, page: Int, apps: [AppInfo]) {
    self.id = UUID()
    self.name = name
    self.apps = apps
    self.page = page
  }

  var previewApps: [AppInfo] {
      Array(apps.prefix(LaunchPadConstants.folderPreviewSize))
   }
}
