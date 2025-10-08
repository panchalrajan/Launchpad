import Foundation

@MainActor
final class SettingsManager: ObservableObject {
   static let shared = SettingsManager()
   
   @Published var settings: LaunchpadSettings {
      didSet { saveSettings() }
   }
   
   private let userDefaults = UserDefaults.standard
   private let settingsKey = "LaunchpadSettings"
   
   private init() {
      self.settings = Self.loadSettings()
   }
   
   private static func loadSettings() -> LaunchpadSettings {
      guard let data = UserDefaults.standard.data(forKey: "LaunchpadSettings"),
            let settings = try? JSONDecoder().decode(LaunchpadSettings.self, from: data)
      else {
         return LaunchpadSettings()
      }
      return settings
   }
   
   private func saveSettings() {
      guard let data = try? JSONEncoder().encode(settings) else { return }
      print("Save settings.")
      userDefaults.set(data, forKey: settingsKey)
      userDefaults.synchronize()
   }
   
   func updateSettings(
      columns: Int? = nil,
      rows: Int? = nil,
      iconSize: Double? = nil,
      dropDelay: Double? = nil,
      folderColumns: Int? = nil,
      folderRows: Int? = nil,
      scrollDebounceInterval: TimeInterval? = nil,
      scrollActivationThreshold: CGFloat? = nil,
      showDock: Bool? = nil,
      transparency: Double? = nil,
      startAtLogin: Bool? = nil
   ) {
      settings = LaunchpadSettings(
         columns: columns ?? settings.columns,
         rows: rows ?? settings.rows,
         iconSize: iconSize ?? settings.iconSize,
         dropDelay: dropDelay ?? settings.dropDelay,
         folderColumns: folderColumns ?? settings.folderColumns,
         folderRows: folderRows ?? settings.folderRows,
         scrollDebounceInterval: scrollDebounceInterval ?? settings.scrollDebounceInterval,
         scrollActivationThreshold: scrollActivationThreshold ?? settings.scrollActivationThreshold,
         showDock: showDock ?? settings.showDock,
         transparency: transparency ?? settings.transparency,
         startAtLogin: startAtLogin ?? settings.startAtLogin,
      )
   }
   
   func resetToDefaults() {
      settings = LaunchpadSettings()
   }
}
