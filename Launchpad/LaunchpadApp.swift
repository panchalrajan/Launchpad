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
            WindowAccessor()
            PagedGridView(
               pages: $appManager.pages,
               settings: settingsManager.settings,
            )

         }
         .background(VisualEffectView(material: .fullScreenUI, blendingMode: .behindWindow))
         .sheet(isPresented: $showSettings) {
            SettingsView()
         }
         .onAppear {
            initialize()
         }
         .onTapGesture {
            AppLauncher.exit()
         }
      }
      .windowStyle(.hiddenTitleBar)
   }

   private func initialize() {
      NSMenu.setMenuBarVisible(false)
      loadGridItems()
      subscribeToSystemEvents()
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
         guard let activatedApp = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else { return }
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
