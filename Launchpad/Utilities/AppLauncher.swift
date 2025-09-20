import Foundation
import AppKit

final class AppLauncher {
    @MainActor static let shared = AppLauncher()
    
    @MainActor func launch(_ path: String) {
        NSWorkspace.shared.open(URL(fileURLWithPath: path))
        NSApp.hide(nil)
    }
    
    @MainActor func exit() {
        NSApp.hide(nil)
    }
}
