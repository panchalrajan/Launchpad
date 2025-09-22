import Foundation
import AppKit

@MainActor
final class AppLauncher {
    static let shared = AppLauncher()
    
    func launch(path: String) {
        NSWorkspace.shared.open(URL(fileURLWithPath: path))
    }
    
    func exit() {
        NSApp.hide(nil)
    }
}
