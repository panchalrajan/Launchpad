import SwiftUI

struct AppInfo: Identifiable {
    let id = UUID()
    let name: String
    let icon: NSImage
    let path: String
}
