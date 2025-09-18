import Foundation

struct LaunchpadSettings: Codable, Equatable {
    var columns: Int
    var rows: Int
    var iconSizeMultiplier: Double
    
    static let defaultColumns = 7
    static let defaultRows = 5
    static let defaultIconSizeMultiplier: Double = 0.6
    
    init(columns: Int = defaultColumns, rows: Int = defaultRows, iconSizeMultiplier: Double = defaultIconSizeMultiplier) {
        // Ensure valid ranges
        self.columns = max(4, min(12, columns))
        self.rows = max(3, min(10, rows))
        self.iconSizeMultiplier = max(0.3, min(1.0, iconSizeMultiplier))
    }
    
    var appsPerPage: Int {
        return columns * rows
    }
}
