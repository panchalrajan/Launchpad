import Foundation

extension String {
    /// Returns the localized version of the string
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    /// Returns the localized version of the string with arguments
    func localized(_ arguments: CVarArg...) -> String {
        return String(format: NSLocalizedString(self, comment: ""), arguments: arguments)
    }
}

/// Localization helper for common strings
struct L10n {
    // MARK: - General
    static let appName = "app_name".localized
    static let settings = "settings".localized
    static let cancel = "cancel".localized
    static let apply = "apply".localized
    static let ok = "ok".localized
    static let close = "close".localized
    
    // MARK: - Settings View
    static let launchpadSettings = "launchpad_settings".localized
    static let resetToDefaults = "reset_to_defaults".localized
    
    // MARK: - Layout Settings
    static let layout = "layout".localized
    static let columns = "columns".localized
    static let rows = "rows".localized
    static let folderColumns = "folder_columns".localized
    static let folderRows = "folder_rows".localized
    static let iconSize = "icon_size".localized
    static let dropAnimationDelay = "drop_animation_delay".localized
    static let pageScrollDebounce = "page_scroll_debounce".localized
    static let pageScrollThreshold = "page_scroll_threshold".localized
    
    // MARK: - Actions Settings
    static let actions = "actions".localized
    static let layoutManagement = "layout_management".localized
    static let exportLayout = "export_layout".localized
    static let importLayout = "import_layout".localized
    static let resetOptions = "reset_options".localized
    static let clearAllApps = "clear_all_apps".localized
    
    // MARK: - Alerts and Confirmations
    static let clearAllAppsTitle = "clear_all_apps_title".localized
    static let clearAllAppsMessage = "clear_all_apps_message".localized
    static let clear = "clear".localized
    
    // MARK: - Search
    static let searchPlaceholder = "search_placeholder".localized
    static let searchAppsPlaceholder = "search_apps_placeholder".localized
    static let noResultsTitle = "no_results_title".localized
    static let noResultsMessage = "no_results_message".localized
    static let noAppsFound = "no_apps_found".localized
    
    // MARK: - Folder Management
    static let folderNamePlaceholder = "folder_name_placeholder".localized
    static let untitledFolder = "untitled_folder".localized
    static let newFolder = "new_folder".localized
    
    // MARK: - Actions Placeholder
    static let actionsPlaceholder = "actions_placeholder".localized
    
    // MARK: - Time Units
    static let secondsShort = "seconds_short".localized
    static let millisecondsShort = "milliseconds_short".localized
    
    // MARK: - Numbers
    static let number10 = "number_10".localized
    static let number200 = "number_200".localized
    static let time00s = "time_0_0s".localized
    static let time30s = "time_3_0s".localized
}
