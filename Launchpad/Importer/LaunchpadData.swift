import Foundation
import SQLite3

struct LaunchpadData {
    let apps: [String: LaunchpadDBApp]
    let groups: [String: LaunchpadGroup]
    let items: [LaunchpadDBItem]
}