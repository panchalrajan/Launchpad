import SwiftUI
import Foundation

struct Folder: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var apps: [AppInfo]
    
    init(name: String, apps: [AppInfo]) {
        self.name = name
        self.apps = apps
    }
    
    var previewApps: [AppInfo] {
        Array(apps.prefix(9))
    }
    
    var isEmpty: Bool {
        apps.isEmpty
    }
}
