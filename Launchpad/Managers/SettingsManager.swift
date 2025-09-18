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
    
    func updateSettings(columns: Int, rows: Int, iconSize: Double, dropDelay: Double) {
        settings = LaunchpadSettings(columns: columns, rows: rows, iconSize: iconSize, dropDelay: dropDelay)
    }
    
    func updateSettings(columns: Int, rows: Int, iconSize: Double) {
        settings = LaunchpadSettings(columns: columns, rows: rows, iconSize: iconSize, dropDelay: settings.dropDelay)
    }
    
    func updateSettings(columns: Int, rows: Int) {
        settings = LaunchpadSettings(columns: columns, rows: rows, iconSize: settings.iconSize, dropDelay: settings.dropDelay)
    }
    
    func updateDropDelay(_ dropDelay: Double) {
        settings = LaunchpadSettings(columns: settings.columns, rows: settings.rows, iconSize: settings.iconSize, dropDelay: dropDelay)
    }
    
    func resetToDefaults() {
        settings = LaunchpadSettings()
    }
}
