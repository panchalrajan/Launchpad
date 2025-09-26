import SwiftUI

@main
struct LaunchpadApp: App {
   @StateObject private var settingsManager = SettingsManager.shared
   @StateObject private var appManager = AppManager.shared
   @State private var showSettings = false
   @State private var importAlertMessage: String?

   var body: some Scene {
      WindowGroup {
         ZStack(alignment: .topTrailing) {
            Color.clear.background(VisualEffectView(material: .fullScreenUI, blendingMode: .behindWindow))
            WindowAccessor()
            PagedGridView(
               pages: $appManager.pages,
               settings: settingsManager.settings,
            )
            .onAppear {
               loadGridItems()
               subscribeToSystemEvents()
            }
            .sheet(isPresented: $showSettings) {
               SettingsView()
            }
            .onTapGesture {
               AppLauncher.exit()
            }
         }
      }
      .windowStyle(.hiddenTitleBar)
      .commands {
         CommandGroup(after: .appInfo) {
            Button("Settings") {
               showSettings = true
            }
            Divider()
            Button("Clear Grid Items") {
               clearGridItems()
            }
            Divider()
            Button("Export Layout to JSON") {
               exportLayoutToJSON()
            }
            Button("Import Layout from JSON") {
               importLayoutFromJSON()
            }
         }
      }
   }

   private func loadGridItems() {
      appManager.loadGridItems(appsPerPage: settingsManager.settings.appsPerPage)
   }

   private func saveGridItems(from pages: [[AppGridItem]]) {
      appManager.pages = pages
   }

   private func clearGridItems() {
      appManager.clearGridItems(appsPerPage: settingsManager.settings.appsPerPage)
   }

   private func exportLayoutToJSON() {
      appManager.exportLayout()
   }

   private func importLayoutFromJSON() {
      appManager.importLayout(appsPerPage: settingsManager.settings.appsPerPage)
   }

   private func subscribeToSystemEvents() {
      NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: .main) { notification in
         guard let info = notification.userInfo,
               let activatedApp = info[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else { return }
         let isSelf = activatedApp.bundleIdentifier == Bundle.main.bundleIdentifier
         Task { @MainActor in
            if (isSelf) {
               print("Entering Launchpad.")
               //loadGridItems()
            } else {
               print("Exiting Launchpad.")
               AppLauncher.exit()
            }
         }
      }
   }
}
