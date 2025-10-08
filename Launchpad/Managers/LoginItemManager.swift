import Foundation
import ServiceManagement

@MainActor
final class LoginItemManager {
   static let shared = LoginItemManager()
   
   @discardableResult
   func enableLoginItem() -> Bool {
      do {
         if #available(macOS 13.0, *) {
            try SMAppService.mainApp.register()
            print("Login item enabled successfully")
            return true
         } else {
            return SMLoginItemSetEnabled("waikiki.program.Launchpad" as CFString, true)
         }
      } catch {
         print("Failed to enable login item: \(error.localizedDescription)")
         return false
      }
   }
   
   @discardableResult
   func disableLoginItem() -> Bool {
      do {
         if #available(macOS 13.0, *) {
            try SMAppService.mainApp.unregister()
            print("Login item disabled successfully")
            return true
         } else {
            return SMLoginItemSetEnabled("waikiki.program.Launchpad" as CFString, false)
         }
      } catch {
         print("Failed to disable login item: \(error.localizedDescription)")
         return false
      }
   }
   
   func isLoginItemEnabled() -> Bool {
      if #available(macOS 13.0, *) {
         return SMAppService.mainApp.status == .enabled
      } else {
         return false
      }
   }
   
   func getLoginItemStatus() -> String {
      if #available(macOS 13.0, *) {
         switch SMAppService.mainApp.status {
         case .enabled:
            return "Enabled"
         case .notRegistered:
            return "Not Registered"
         case .notFound:
            return "Not Found"
         case .requiresApproval:
            return "Requires Approval"
         @unknown default:
            return "Unknown"
         }
      } else {
         return "Unknown"
      }
   }
}
