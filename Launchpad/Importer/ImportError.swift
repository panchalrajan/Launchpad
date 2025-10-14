import Foundation
import SQLite3

enum ImportError: LocalizedError {
    case databaseNotFound(String)
    case databaseError(String)
    case systemError(String)
    case conversionError(String)

    var errorDescription: String? {
        switch self {
        case .databaseNotFound(let msg):
            return "Database not found: \(msg)"
        case .databaseError(let msg):
            return "Database error: \(msg)"
        case .systemError(let msg):
            return "System error: \(msg)"
        case .conversionError(let msg):
            return "Conversion error: \(msg)"
        }
    }
}
