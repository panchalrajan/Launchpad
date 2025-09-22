import SwiftUI
import AppKit

struct AppInfo: Identifiable, Equatable {
    let id: UUID
    let name: String
    let icon: NSImage
    let path: String
    var page: Int
    
    init(id: UUID = UUID(), name: String, icon: NSImage, path: String, page: Int = 0) {
        self.id = id
        self.name = name
        self.icon = icon
        self.path = path
        self.page = page
    }
}

