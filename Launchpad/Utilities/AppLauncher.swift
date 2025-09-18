import Foundation
import AppKit

final class AppLauncher {
    @MainActor static let shared = AppLauncher()
    
    @MainActor func launch(_ path: String) {
        NSWorkspace.shared.open(URL(fileURLWithPath: path))
        NSApp.terminate(nil)
    }
    
    @MainActor func exit() {
        //NSApp.terminate(nil)
    }
}
