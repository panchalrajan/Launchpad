import SwiftUI
import Foundation

struct Folder: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var apps: [AppInfo]
    var color: FolderColor
    
    init(name: String, apps: [AppInfo], color: FolderColor = .blue) {
        self.name = name
        self.apps = apps
        self.color = color
    }
    
    var previewApps: [AppInfo] {
        Array(apps.prefix(4))
    }
    
    var isEmpty: Bool {
        apps.isEmpty
    }
}

enum FolderColor: String, CaseIterable, Codable {
    case blue = "blue"
    case green = "green"
    case orange = "orange"
    case purple = "purple"
    case pink = "pink"
    case red = "red"
    case yellow = "yellow"
    case gray = "gray"
    
    var color: Color {
        switch self {
        case .blue: return .blue
        case .green: return .green
        case .orange: return .orange
        case .purple: return .purple
        case .pink: return .pink
        case .red: return .red
        case .yellow: return .yellow
        case .gray: return .gray
        }
    }
}
