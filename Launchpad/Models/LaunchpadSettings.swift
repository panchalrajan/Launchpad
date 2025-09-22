import Foundation

struct LaunchpadSettings: Codable, Equatable {
  var columns: Int
  var rows: Int
  var iconSize: Double
  var dropDelay: Double

  static let defaultColumns = 7
  static let defaultRows = 5
  static let defaultIconSize: Double = 100.0
  static let defaultDropDelay: Double = 0.5

  init(
    columns: Int = defaultColumns, rows: Int = defaultRows, iconSize: Double = defaultIconSize,
    dropDelay: Double = defaultDropDelay
  ) {
    self.columns = max(4, min(12, columns))
    self.rows = max(3, min(10, rows))
    self.iconSize = max(20, min(200, iconSize))
    self.dropDelay = max(0.0, min(3.0, dropDelay))
  }

  var appsPerPage: Int {
    return columns * rows
  }
}
