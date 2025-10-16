import SwiftUI

@main
struct LaunchpadApp: App {
   @StateObject private var settingsManager = SettingsManager.shared
   @StateObject private var appManager = AppManager.shared
   @State private var showSettings = false
   @State private var isInitialized = false

   var body: some Scene {
      WindowGroup {
         ZStack {
            WindowAccessor()
            PagedGridView(
               pages: $appManager.pages,
               showSettings: $showSettings,
               settings: settingsManager.settings
            )
            .opacity(showSettings ? 0.3 : 1.0)
            .animation(LaunchPadConstants.fadeAnimation, value: showSettings)
            .onTapGesture(perform: AppLauncher.exit)

            if showSettings {
               SettingsView(onDismiss: { showSettings = false }, initialTab: settingsManager.settings.isActivated ? 0 : 5)
            }
         }
         .background(VisualEffectView(material: .fullScreenUI, blendingMode: .behindWindow))
         .onAppear(perform: initialize)
      }
   }

   private func initialize() {
      guard !isInitialized else { return }
      appManager.loadGridItems(appsPerPage: settingsManager.settings.appsPerPage)
      isInitialized = true

      if(settingsManager.settings.showDock) {
         NSMenu.setMenuBarVisible(true)
      } else {
         NSMenu.setMenuBarVisible(false)
      }
   }
}
