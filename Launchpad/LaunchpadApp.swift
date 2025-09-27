import SwiftUI

@main
struct LaunchpadApp: App {
   @StateObject private var settingsManager = SettingsManager.shared
   @StateObject private var appManager = AppManager.shared
   @State private var showSettings = false

   var body: some Scene {
      WindowGroup {
         ZStack(alignment: .topTrailing) {
            WindowAccessor()
            PagedGridView(
               pages: $appManager.pages,
               settings: settingsManager.settings,
               showSettings: { showSettings = true }
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
      appManager.loadGridItems(appsPerPage: settingsManager.settings.appsPerPage)
   }
}
