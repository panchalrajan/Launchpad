import SwiftUI

struct AppInfo: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let icon: NSImage
    let path: String
}
