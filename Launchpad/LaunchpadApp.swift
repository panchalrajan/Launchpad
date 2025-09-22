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
        .ignoresSafeArea()
        .onAppear {
          loadGridItems()
          subscribeToSystemEvents()
        }
        .onChange(of: settingsManager.settings) { oldSettings, newSettings in
          loadGridItems()
        }
        .sheet(isPresented: $showSettings) {
          SettingsView()
            .interactiveDismissDisabled(false)
        }
        .onTapGesture {
          AppLauncher.exit()
        }
      }
      .alert(importAlertMessage ?? "", isPresented: Binding(
        get: { importAlertMessage != nil },
        set: { if !$0 { importAlertMessage = nil } }
      )) {
        Button("OK", role: .cancel) { importAlertMessage = nil }
      }
    }
    .windowStyle(.hiddenTitleBar)
    .commands {
      CommandGroup(after: .appInfo) {
        Button("Settings") {
          showSettings = true
        }
        Divider()
        Button("Import from Native Launchpad…") {
          runNativeImport()
        }
        Button("Clear Grid Items") {
          clearGridItems()
        }
      }
    }
  }

  private func runNativeImport() {
    let importer = NativeLaunchpadImporter()
    do {
      let result = try importer.importFromNativeLaunchpad()
      importAlertMessage = result.summary
    } catch {
      importAlertMessage = (error as? LocalizedError)?.errorDescription ?? "Import failed: \(error.localizedDescription)"
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

  private func subscribeToSystemEvents() {
    // Subscribe to app opened
    NSWorkspace.shared.notificationCenter.addObserver(
      forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: .main
    ) { notification in
      if let info = notification.userInfo,
        let activatedApp = info[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
      {
        if activatedApp.bundleIdentifier != Bundle.main.bundleIdentifier {
          Task { @MainActor in
            print(
              "Exiting Launchpad because \(activatedApp.bundleIdentifier ?? "unknown") was activated"
            )
            AppLauncher.exit()
          }
        }
      }
    }
  }
}
