import Foundation

final class SettingsManager: ObservableObject {
    nonisolated(unsafe) static let shared = SettingsManager()
    
    @Published var settings: LaunchpadSettings {
        didSet {
            saveSettings()
        }
    }
    
    private let userDefaults = UserDefaults.standard
    private let settingsKey = "LaunchpadSettings"
    
    private init() {
        self.settings = Self.loadSettings()
    }
    
    private static func loadSettings() -> LaunchpadSettings {
        guard let data = UserDefaults.standard.data(forKey: "LaunchpadSettings"),
              let settings = try? JSONDecoder().decode(LaunchpadSettings.self, from: data) else {
            print("No saved settings found, using defaults")
            return LaunchpadSettings()
        }
        
        print("Settings loaded: \(settings.columns) columns, \(settings.rows) rows")
        return settings
    }
    
    private func saveSettings() {
        guard let data = try? JSONEncoder().encode(settings) else {
            print("Failed to encode settings")
            return
        }
        
        userDefaults.set(data, forKey: settingsKey)
        userDefaults.synchronize()
        print("Settings saved: \(settings.columns) columns, \(settings.rows) rows, icon size: \(settings.iconSizeMultiplier)")
    }
    
    func updateSettings(columns: Int, rows: Int, iconSizeMultiplier: Double) {
        settings = LaunchpadSettings(columns: columns, rows: rows, iconSizeMultiplier: iconSizeMultiplier)
    }
    
    func updateSettings(columns: Int, rows: Int) {
        settings = LaunchpadSettings(columns: columns, rows: rows, iconSizeMultiplier: settings.iconSizeMultiplier)
    }
    
    func resetToDefaults() {
        settings = LaunchpadSettings()
    }
}
