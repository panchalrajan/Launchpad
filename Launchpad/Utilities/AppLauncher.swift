import AppKit
import Foundation

@MainActor
final class AppLauncher {
  static func launch(path: String) {
    NSWorkspace.shared.open(URL(fileURLWithPath: path))
  }

  static func exit() {
    print("Exiting Launchpad")
    NSApp.hide(nil)
  }
}
