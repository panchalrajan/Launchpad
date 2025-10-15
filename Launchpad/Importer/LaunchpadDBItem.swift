import Foundation
import SQLite3

struct LaunchpadDBItem {
    let rowId: String
    let type: Int  // 1=root, 2=page, 3=folder, 4=app
    let parentId: Int
    let ordering: Int
}
