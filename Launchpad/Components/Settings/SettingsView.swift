import SwiftUI

struct SettingsView: View {
   private let settingsManager = SettingsManager.shared
   private let appManager = AppManager.shared
   let onDismiss: () -> Void

   @State private var selectedTab = 0
   @State private var settings: LaunchpadSettings = SettingsManager.shared.settings

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

            Picker("", selection: $selectedTab) {
               Label(L10n.layout, systemImage: "grid").tag(0)
               Label(L10n.actions, systemImage: "bolt").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.bottom, 16)

            Group {
               if selectedTab == 0 {
                  LayoutSettings(settings: $settings)
               } else {
                  ActionsSettings()
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

         .padding(24)
         .frame(width: 480, height: 520)
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

      settingsManager.updateSettings(
         columns: settings.columns,
         rows: settings.rows,
         iconSize: settings.iconSize,
         dropDelay: settings.dropDelay,
         folderColumns: settings.folderColumns,
         folderRows: settings.folderRows,
         scrollDebounceInterval: settings.scrollDebounceInterval,
         scrollActivationThreshold: CGFloat(settings.scrollActivationThreshold)
      )

      // Recalculate pages if the number of apps per page changed
      if oldAppsPerPage != newAppsPerPage {
         appManager.recalculatePages(appsPerPage: newAppsPerPage)
      }
   }
}
