import SwiftUI

@main
struct LaunchpadApp: App {
   @StateObject private var settingsManager = SettingsManager.shared
   @StateObject private var appManager = AppManager.shared
   @State private var showSettings = false

   var body: some Scene {
      WindowGroup {
         ZStack {
            // Main content
            ZStack(alignment: .topTrailing) {
               WindowAccessor()
               PagedGridView(
                  pages: $appManager.pages,
                  settings: settingsManager.settings,
                  showSettings: { 
                     withAnimation(.easeInOut(duration: 0.3)) {
                        showSettings = true
                     }
                  }
               )
            }
            .opacity(showSettings ? 0.3 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: showSettings)
            
            // Settings overlay - centered
            if showSettings {
               ZStack {
                  // Background overlay
                  Color.black.opacity(0.4)
                     .ignoresSafeArea()
                     .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                           showSettings = false
                        }
                     }
                  
                  // Centered settings view
                  SettingsView(onDismiss: { 
                     withAnimation(.easeInOut(duration: 0.3)) {
                        showSettings = false
                     }
                  })
                  .transition(.scale(scale: 0.8).combined(with: .opacity))
               }
               .zIndex(1)
               .transition(.opacity)
            }
         }
         .background(VisualEffectView(material: .fullScreenUI, blendingMode: .behindWindow))
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
