import AppKit
import SwiftUI

struct AppInfo: Identifiable, Equatable {
  let id: UUID
  let name: String
  let icon: NSImage
  let path: String
  var page: Int

  init(name: String, icon: NSImage, path: String, page: Int = 0) {
    self.id = UUID()
    self.name = name
    self.icon = icon
    self.path = path
    self.page = page
  }
}
