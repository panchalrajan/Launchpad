import Foundation
import AppKit

@MainActor
final class AppLauncher {
    static let shared = AppLauncher()
    
    func launch(_ path: String) {
        NSWorkspace.shared.open(URL(fileURLWithPath: path))
        NSApp.hide(nil)
    }
    
    func exit() {
        NSApp.hide(nil)
    }
}
