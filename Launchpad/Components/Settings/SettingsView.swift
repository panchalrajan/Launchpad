import SwiftUI

struct SettingsView: View {
   private let settingsManager = SettingsManager.shared
   private let appManager = AppManager.shared
   let onDismiss: () -> Void
   
   @State private var selectedTab: Int
   @State private var settings: LaunchpadSettings = SettingsManager.shared.settings
   
   init(onDismiss: @escaping () -> Void, initialTab: Int = 0) {
      self.onDismiss = onDismiss;
      _selectedTab = State(initialValue: initialTab)
   }
   
   var body: some View {
      ZStack {
         Color.black.opacity(0.4)
            .ignoresSafeArea()
            .onTapGesture(perform: onDismiss)

         VStack(spacing: 0) {
            HStack {
               Text(L10n.launchpadSettings)
                  .font(.title2)
                  .fontWeight(.semibold)
               Spacer()
               Button("✕", action: onDismiss)
                  .buttonStyle(.plain)
                  .foregroundColor(.secondary)
                  .font(.title3)
            }
            .padding(.bottom, 16)
            
            HStack(spacing: 0) {
               // Sidebar with vertical tabs
               VStack(alignment: .leading, spacing: 4) {
                  SidebarTabButton(
                     icon: "grid",
                     label: L10n.layout,
                     isSelected: selectedTab == 0,
                     action: { selectedTab = 0 }
                  )
                  SidebarTabButton(
                     icon: "sparkles",
                     label: L10n.features,
                     isSelected: selectedTab == 1,
                     action: { selectedTab = 1 }
                  )
                  SidebarTabButton(
                     icon: "bolt",
                     label: L10n.actions,
                     isSelected: selectedTab == 2,
                     action: { selectedTab = 2 }
                  )
                  SidebarTabButton(
                     icon: "eye.slash",
                     label: L10n.hiddenApps,
                     isSelected: selectedTab == 3,
                     action: { selectedTab = 3 }
                  )
                  SidebarTabButton(
                     icon: "folder",
                     label: L10n.locations,
                     isSelected: selectedTab == 4,
                     action: { selectedTab = 4 }
                  )
                  SidebarTabButton(
                     icon: "key.fill",
                     label: L10n.activation,
                     isSelected: selectedTab == 5,
                     action: { selectedTab = 5 }
                  )
                  Spacer()
               }
               .frame(width: 200)
               .padding(.trailing, 16)
               
               Divider()
                  .padding(.trailing, 16)
               
               // Content area
               VStack {
                  Group {
                     if selectedTab == 0 {
                        LayoutSettings(settings: $settings)
                     } else if selectedTab == 1 {
                        FeaturesSettings(settings: $settings)
                     } else if selectedTab == 2 {
                        ActionsSettings()
                     } else if selectedTab == 3 {
                        HiddenAppsSettings()
                     } else if selectedTab == 4 {
                        LocationsSettings(settings: $settings)
                     } else {
                        ActivationSettings(settings: $settings)
                     }
                  }
                  
                  Spacer()
                  
                  HStack(spacing: 16) {
                     Button(L10n.resetToDefaults, action: reset).buttonStyle(.bordered)
                     Spacer()
                     Button(L10n.cancel, action: onDismiss).buttonStyle(.bordered)
                     Button(L10n.apply, action: apply).buttonStyle(.borderedProminent)
                  }
               }
            }
         }
         
         .padding(24)
         .frame(width: 720, height: 460)
         .background(
            RoundedRectangle(cornerRadius: 16)
               .fill(.regularMaterial)
               .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
         )
         .overlay(
            RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.2), lineWidth: 1)
         )
      }
   }
   
   private func apply() {
      updateSettings()
      onDismiss()
   }
   
   private func reset() {
      settings = LaunchpadSettings()
      updateSettings()
   }
   
   private func updateSettings() {
      let oldAppsPerPage = settingsManager.settings.appsPerPage
      let newAppsPerPage = settings.appsPerPage
      let oldLocations = settingsManager.settings.customAppLocations
      let newLocations = settings.customAppLocations
      
      settingsManager.updateSettings(
         columns: settings.columns,
         rows: settings.rows,
         iconSize: settings.iconSize,
         dropDelay: settings.dropDelay,
         folderColumns: settings.folderColumns,
         folderRows: settings.folderRows,
         scrollDebounceInterval: settings.scrollDebounceInterval,
         scrollActivationThreshold: CGFloat(settings.scrollActivationThreshold),
         showDock: settings.showDock,
         transparency: settings.transparency,
         startAtLogin: settings.startAtLogin,
         resetOnRelaunch: settings.resetOnRelaunch,
         productKey: settings.productKey,
         customAppLocations: settings.customAppLocations
      )
      
      // Recalculate pages if the number of apps per page changed
      if oldAppsPerPage != newAppsPerPage {
         appManager.recalculatePages(appsPerPage: newAppsPerPage)
      }
      
      // Reload apps if custom locations changed
      if oldLocations != newLocations {
         appManager.loadGridItems(appsPerPage: settings.appsPerPage)
      }
   }
}
