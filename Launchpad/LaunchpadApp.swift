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
                    settings: settingsManager.settings,
                    showSettings: { showSettings = true }
                )
                .opacity(showSettings ? 0.3 : 1.0)
                .animation(LaunchPadConstants.fadeAnimation, value: showSettings)
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
        guard !isInitialized else { return }
        appManager.loadGridItems(appsPerPage: settingsManager.settings.appsPerPage)
        isInitialized = true
        if(settingsManager.settings.showDock) {
            subscribeToSystemEvents()
            NSMenu.setMenuBarVisible(true)
        } else {
            NSMenu.setMenuBarVisible(false)
        }
        
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
