import SwiftUI

struct SettingsView: View {
   var settingsManager = SettingsManager.shared
   var onDismiss: () -> Void

   @State private var tempColumns: Int
   @State private var tempRows: Int
   @State private var tempIconSize: Double
   @State private var tempDropDelay: Double
   @State private var tempFolderColumns: Int
   @State private var tempFolderRows: Int
   @State private var tempScrollDebounceInterval: Double
   @State private var tempScrollActivationThreshold: Double
   @State private var selectedTab: Int = 0

   init(onDismiss: @escaping () -> Void = {}) {
      self.onDismiss = onDismiss
      let currentSettings = SettingsManager.shared.settings
      _tempColumns = State(initialValue: currentSettings.columns)
      _tempRows = State(initialValue: currentSettings.rows)
      _tempIconSize = State(initialValue: currentSettings.iconSize)
      _tempDropDelay = State(initialValue: currentSettings.dropDelay)
      _tempFolderColumns = State(initialValue: currentSettings.folderColumns)
      _tempFolderRows = State(initialValue: currentSettings.folderRows)
      _tempScrollDebounceInterval = State(initialValue: currentSettings.scrollDebounceInterval)
      _tempScrollActivationThreshold = State(initialValue: Double(currentSettings.scrollActivationThreshold))
   }

   var body: some View {
      VStack(spacing: 0) {
         HStack {
            Text(L10n.launchpadSettings)
               .font(.title2)
               .fontWeight(.semibold)
            Spacer()
            Button("✕") {
               onDismiss()
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
            .font(.title3)
         }
         .padding(.bottom, 16)

         TabView(selection: $selectedTab) {
            layoutTab
               .tabItem {
                  Label(L10n.layout, systemImage: "grid")
               }
               .tag(0)

            actionsTab
               .tabItem {
                  Label(L10n.actions, systemImage: "bolt")
               }
               .tag(1)
         }
         .frame(maxHeight: .infinity)

         Spacer()

         HStack(spacing: 16) {
            Button(L10n.resetToDefaults) {
               reset()
            }
            .buttonStyle(.bordered)

            Spacer()

            Button(L10n.cancel) {
               onDismiss()
            }
            .buttonStyle(.bordered)

            Button(L10n.apply) {
               apply()
            }
            .buttonStyle(.borderedProminent)
         }
      }
      .padding(24)
      .frame(width: 480, height: 500)
      .background(
         RoundedRectangle(cornerRadius: 16)
            .fill(.regularMaterial)
            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
      )
      .overlay(
         RoundedRectangle(cornerRadius: 16)
            .stroke(Color.white.opacity(0.2), lineWidth: 1)
      )
   }

   private var layoutTab: some View {
      LayoutSettings(
         tempColumns: $tempColumns,
         tempRows: $tempRows,
         tempIconSize: $tempIconSize,
         tempDropDelay: $tempDropDelay,
         tempFolderColumns: $tempFolderColumns,
         tempFolderRows: $tempFolderRows,
         tempScrollDebounceInterval: $tempScrollDebounceInterval,
         tempScrollActivationThreshold: $tempScrollActivationThreshold
      )
   }

   private var actionsTab: some View {
      ActionsSettings()
   }

   private func apply() {
      settingsManager.updateSettings(
         columns: tempColumns,
         rows: tempRows,
         iconSize: tempIconSize,
         dropDelay: tempDropDelay,
         folderColumns: tempFolderColumns,
         folderRows: tempFolderRows,
         scrollDebounceInterval: tempScrollDebounceInterval,
         scrollActivationThreshold: CGFloat(tempScrollActivationThreshold)
      )
      onDismiss()
   }

   private func reset() {
      tempColumns = LaunchpadSettings.defaultColumns
      tempRows = LaunchpadSettings.defaultRows
      tempIconSize = LaunchpadSettings.defaultIconSize
      tempDropDelay = LaunchpadSettings.defaultDropDelay
      tempFolderColumns = LaunchpadSettings.defaultFolderColumns
      tempFolderRows = LaunchpadSettings.defaultFolderRows
      tempScrollDebounceInterval = LaunchpadSettings.defaultScrollDebounceInterval
      tempScrollActivationThreshold = Double(LaunchpadSettings.defaultScrollActivationThreshold)
   }
}
