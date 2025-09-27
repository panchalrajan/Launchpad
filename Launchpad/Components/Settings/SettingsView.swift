import SwiftUI

struct SettingsView: View {
   private let settingsManager = SettingsManager.shared
   private let onDismiss: () -> Void

   @State private var tempColumns: Int
   @State private var tempRows: Int
   @State private var tempIconSize: Double
   @State private var tempDropDelay: Double
   @State private var tempFolderColumns: Int
   @State private var tempFolderRows: Int
   @State private var tempScrollDebounceInterval: Double
   @State private var tempScrollActivationThreshold: Double
   @State private var selectedTab = 0

   init(onDismiss: @escaping () -> Void = {}) {
      self.onDismiss = onDismiss
      let settings = SettingsManager.shared.settings
      _tempColumns = State(initialValue: settings.columns)
      _tempRows = State(initialValue: settings.rows)
      _tempIconSize = State(initialValue: settings.iconSize)
      _tempDropDelay = State(initialValue: settings.dropDelay)
      _tempFolderColumns = State(initialValue: settings.folderColumns)
      _tempFolderRows = State(initialValue: settings.folderRows)
      _tempScrollDebounceInterval = State(initialValue: settings.scrollDebounceInterval)
      _tempScrollActivationThreshold = State(initialValue: Double(settings.scrollActivationThreshold))
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

         Picker("", selection: $selectedTab) {
            Label(L10n.layout, systemImage: "grid").tag(0)
            Label(L10n.actions, systemImage: "bolt").tag(1)
         }
         .pickerStyle(.segmented)
         .padding(.bottom, 16)

         Group {
            if selectedTab == 0 {
               LayoutSettings(
                  tempColumns: $tempColumns,
                  tempRows: $tempRows,
                  tempIconSize: $tempIconSize,
                  tempDropDelay: $tempDropDelay,
                  tempFolderColumns: $tempFolderColumns,
                  tempFolderRows: $tempFolderRows,
                  tempScrollDebounceInterval: $tempScrollDebounceInterval,
                  tempScrollActivationThreshold: $tempScrollActivationThreshold)
            } else {
               ActionsSettings()
            }
         }

            HStack(spacing: 16) {
               Button(L10n.resetToDefaults, action: reset).buttonStyle(.bordered)
               Spacer()
               Button(L10n.cancel, action: onDismiss).buttonStyle(.bordered)
               Button(L10n.apply, action: apply).buttonStyle(.borderedProminent)
            }
         }

         .padding(24)
         .frame(width: 480, height: 500)
         .background(
            RoundedRectangle(cornerRadius: 16)
               .fill(.regularMaterial)
               .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
         )
         .overlay(
            RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.2), lineWidth: 1)
         )
         .onTapGesture(perform: {})
      }
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
