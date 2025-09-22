import Foundation

@MainActor
final class SettingsManager {
  static let shared = SettingsManager()

  public var settings: LaunchpadSettings

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
    guard let data = try? JSONEncoder().encode(settings) else {
      return
    }

    userDefaults.set(data, forKey: settingsKey)
    userDefaults.synchronize()
  }

  func updateSettings(
    columns: Int? = nil, rows: Int? = nil, iconSize: Double? = nil, dropDelay: Double? = nil
  ) {
    settings = LaunchpadSettings(
      columns: columns ?? settings.columns,
      rows: rows ?? settings.rows,
      iconSize: iconSize ?? settings.iconSize,
      dropDelay: dropDelay ?? settings.dropDelay
    )
  }

  func resetToDefaults() {
    settings = LaunchpadSettings()
  }
}
