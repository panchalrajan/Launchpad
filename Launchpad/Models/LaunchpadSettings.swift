import Foundation

struct LaunchpadSettings: Codable, Equatable {
    var columns: Int
    var rows: Int
    
    static let defaultColumns = 7
    static let defaultRows = 5
    
    init(columns: Int = defaultColumns, rows: Int = defaultRows) {
        // Ensure valid ranges
        self.columns = max(4, min(10, columns))
        self.rows = max(3, min(8, rows))
    }
    
    var appsPerPage: Int {
        return columns * rows
    }
}
