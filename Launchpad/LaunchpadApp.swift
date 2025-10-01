import SwiftUI

@main
struct LaunchpadApp: App {
   @StateObject private var settingsManager = SettingsManager.shared
   @StateObject private var appManager = AppManager.shared
   @State private var showSettings = false

   var body: some Scene {
      WindowGroup {
         ZStack {
            WindowAccessor()
            PagedGridView(
               pages: $appManager.pages,
               settings: settingsManager.settings,
               showSettings: { showSettings = true }
            )
            .opacity(showSettings ? 0.3 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: showSettings)
                .onTapGesture(perform: AppLauncher.exit)

            if showSettings {
               SettingsView(onDismiss: { showSettings = false })
            }
         }
         .background(VisualEffectView(material: .fullScreenUI, blendingMode: .behindWindow))
         .onAppear(perform: initialize)
      }
      .windowStyle(.hiddenTitleBar)
   }

   private func initialize() {
      appManager.loadGridItems(appsPerPage: settingsManager.settings.appsPerPage)
      NSMenu.setMenuBarVisible(false)
   }
}
