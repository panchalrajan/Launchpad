import AppKit
import SwiftUI

struct AppInfo: Identifiable, Equatable, Hashable {
   let id: UUID
   let name: String
   let icon: NSImage
   let path: String
   let bundleId: String
   var page: Int

   init(name: String, icon: NSImage, path: String, bundleId: String, page: Int = 0) {
      self.id = UUID()
      self.name = name
      self.icon = icon
      self.path = path
      self.bundleId = bundleId
      self.page = page
   }
}
