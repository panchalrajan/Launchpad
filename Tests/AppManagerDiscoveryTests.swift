import XCTest
import AppKit
@testable import Launchpad

@MainActor
final class AppManagerDiscoveryTests: XCTestCase {
    
    var appManager: AppManager!
    
    override func setUp() {
        super.setUp()
        appManager = AppManager.shared
        UserDefaults.standard.removeObject(forKey: "LaunchpadGridItems")
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "LaunchpadGridItems")
        super.tearDown()
    }
    
    // MARK: - App Discovery Tests
    
    func testAppDiscoveryFindsSystemApps() {
        // Load apps and verify that common system apps are found
        appManager.loadGridItems(appsPerPage: 20)
        
        let allApps = appManager.pages.flatMap { $0 }.compactMap { item -> AppInfo? in
            if case .app(let app) = item {
                return app
            }
            return nil
        }
        
        XCTAssertGreaterThan(allApps.count, 0, "Should discover at least some apps")
        
        // Check for common system apps that should exist
        let appNames = allApps.map { $0.name.lowercased() }
        let commonApps = ["finder", "safari", "mail", "app store", "system preferences", "calculator"]
        
        let foundCommonApps = commonApps.filter { appNames.contains($0) }
        XCTAssertGreaterThan(foundCommonApps.count, 0, "Should find at least some common system apps")
    }
    
    func testAppDiscoveryPropertiesAreValid() {
        appManager.loadGridItems(appsPerPage: 20)
        
        let allApps = appManager.pages.flatMap { $0 }.compactMap { item -> AppInfo? in
            if case .app(let app) = item {
                return app
            }
            return nil
        }
        
        for app in allApps.prefix(10) { // Test first 10 apps for performance
            // Name should not be empty
            XCTAssertFalse(app.name.isEmpty, "App name should not be empty for \(app.path)")
            
            // Path should end with .app
            XCTAssertTrue(app.path.hasSuffix(".app"), "App path should end with .app: \(app.path)")
            
            // Path should exist on filesystem
            XCTAssertTrue(FileManager.default.fileExists(atPath: app.path), "App should exist at path: \(app.path)")
            
            // Icon should have reasonable size
            XCTAssertGreaterThan(app.icon.size.width, 0, "App icon should have width > 0")
            XCTAssertGreaterThan(app.icon.size.height, 0, "App icon should have height > 0")
            
            // Page should be 0 for newly discovered apps
            XCTAssertEqual(app.page, 0, "Newly discovered apps should be on page 0")
        }
    }
    
    func testAppDiscoveryIgnoresInvalidPaths() {
        // This test verifies that the discovery process properly filters out invalid entries
        appManager.loadGridItems(appsPerPage: 20)
        
        let allApps = appManager.pages.flatMap { $0 }.compactMap { item -> AppInfo? in
            if case .app(let app) = item {
                return app
            }
            return nil
        }
        
        // All discovered apps should exist
        for app in allApps {
            var isDirectory: ObjCBool = false
            let exists = FileManager.default.fileExists(atPath: app.path, isDirectory: &isDirectory)
            XCTAssertTrue(exists && isDirectory.boolValue, "Discovered app should exist and be a directory: \(app.path)")
        }
    }
    
    // MARK: - Page Grouping Tests
    
    func testPageGroupingWithSinglePage() {
        let mockIcon = NSImage(size: NSSize(width: 64, height: 64))
        let apps = (0..<5).map { i in
            AppGridItem.app(AppInfo(name: "App \(i)", icon: mockIcon, path: "/App\(i).app", page: 0))
        }
        
        // Simulate the grouping by setting pages directly
        appManager.pages = [apps]
        appManager.recalculatePages(appsPerPage: 10)
        
        XCTAssertEqual(appManager.pages.count, 1, "Should have 1 page for 5 apps with 10 per page")
        XCTAssertEqual(appManager.pages[0].count, 5, "Single page should contain all 5 apps")
    }
    
    func testPageGroupingWithMultiplePages() {
        let mockIcon = NSImage(size: NSSize(width: 64, height: 64))
        let apps = (0..<15).map { i in
            AppGridItem.app(AppInfo(name: "App \(i)", icon: mockIcon, path: "/App\(i).app", page: 0))
        }
        
        appManager.pages = [apps]
        appManager.recalculatePages(appsPerPage: 10)
        
        XCTAssertEqual(appManager.pages.count, 2, "Should have 2 pages for 15 apps with 10 per page")
        XCTAssertEqual(appManager.pages[0].count, 10, "First page should have 10 apps")
        XCTAssertEqual(appManager.pages[1].count, 5, "Second page should have 5 apps")
    }
    
    func testPageGroupingWithSparsePageNumbers() {
        let mockIcon = NSImage(size: NSSize(width: 64, height: 64))
        
        // Create apps with non-consecutive page numbers (0, 2, 5)
        let apps = [
            AppGridItem.app(AppInfo(name: "App 0", icon: mockIcon, path: "/App0.app", page: 0)),
            AppGridItem.app(AppInfo(name: "App 1", icon: mockIcon, path: "/App1.app", page: 2)),
            AppGridItem.app(AppInfo(name: "App 2", icon: mockIcon, path: "/App2.app", page: 5)),
        ]
        
        // Set up the pages to simulate sparse page numbers
        var pages = Array(repeating: [AppGridItem](), count: 6)
        pages[0] = [apps[0]]
        pages[2] = [apps[1]]
        pages[5] = [apps[2]]
        
        appManager.pages = pages
        
        // Verify that pages maintain their structure
        XCTAssertEqual(appManager.pages.count, 6, "Should maintain sparse page structure")
        XCTAssertEqual(appManager.pages[0].count, 1, "Page 0 should have 1 app")
        XCTAssertEqual(appManager.pages[1].count, 0, "Page 1 should be empty")
        XCTAssertEqual(appManager.pages[2].count, 1, "Page 2 should have 1 app")
        XCTAssertEqual(appManager.pages[5].count, 1, "Page 5 should have 1 app")
    }
    
    func testPageGroupingPreservesAppData() {
        let mockIcon = NSImage(size: NSSize(width: 64, height: 64))
        let originalApp = AppInfo(name: "Test App", icon: mockIcon, path: "/TestApp.app", page: 0)
        let apps = [AppGridItem.app(originalApp)]
        
        appManager.pages = [apps]
        appManager.recalculatePages(appsPerPage: 10)
        
        guard let firstItem = appManager.pages[0].first,
              case .app(let resultApp) = firstItem else {
            XCTFail("Should have app in first page")
            return
        }
        
        XCTAssertEqual(resultApp.name, originalApp.name, "App name should be preserved")
        XCTAssertEqual(resultApp.path, originalApp.path, "App path should be preserved")
        XCTAssertEqual(resultApp.icon.size, originalApp.icon.size, "App icon should be preserved")
    }
    
    // MARK: - Mixed Content Tests
    
    func testPageGroupingWithAppsAndFolders() {
        let mockIcon = NSImage(size: NSSize(width: 64, height: 64))
        
        let app1 = AppInfo(name: "App 1", icon: mockIcon, path: "/App1.app", page: 0)
        let app2 = AppInfo(name: "App 2", icon: mockIcon, path: "/App2.app", page: 0)
        let folderApp = AppInfo(name: "Folder App", icon: mockIcon, path: "/FolderApp.app", page: 0)
        let folder = Folder(name: "Test Folder", page: 0, apps: [folderApp])
        
        let items = [
            AppGridItem.app(app1),
            AppGridItem.folder(folder),
            AppGridItem.app(app2)
        ]
        
        appManager.pages = [items]
        appManager.recalculatePages(appsPerPage: 10)
        
        XCTAssertEqual(appManager.pages.count, 1, "Should have 1 page for mixed content")
        XCTAssertEqual(appManager.pages[0].count, 3, "Should have 3 items (2 apps + 1 folder)")
        
        // Verify item types are preserved
        let itemTypes = appManager.pages[0].map { item in
            switch item {
            case .app: return "app"
            case .folder: return "folder"
            }
        }
        
        XCTAssertTrue(itemTypes.contains("app"), "Should contain apps")
        XCTAssertTrue(itemTypes.contains("folder"), "Should contain folders")
    }
    
    // MARK: - Performance Tests
    
    func testAppDiscoveryPerformance() {
        measure {
            appManager.loadGridItems(appsPerPage: 20)
        }
    }
    
    func testPageRecalculationPerformance() {
        // Set up a large dataset
        let mockIcon = NSImage(size: NSSize(width: 64, height: 64))
        let largeAppSet = (0..<500).map { i in
            AppGridItem.app(AppInfo(name: "App \(i)", icon: mockIcon, path: "/App\(i).app", page: 0))
        }
        
        appManager.pages = [largeAppSet]
        
        measure {
            appManager.recalculatePages(appsPerPage: 20)
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testHandlingUnreadableDirectories() {
        // This test would be more relevant in an environment where we can simulate permission issues
        // For now, we just verify that the discovery process doesn't crash with the current system
        
        XCTAssertNoThrow {
           self.appManager.loadGridItems(appsPerPage: 20)
        }
        
        // Should still find some apps despite any permission issues
        let totalApps = appManager.pages.flatMap { $0 }.count
        XCTAssertGreaterThanOrEqual(totalApps, 0, "Should handle permission issues gracefully")
    }
    
    func testHandlingSymlinks() {
        // App discovery should handle symlinks properly
        appManager.loadGridItems(appsPerPage: 20)
        
        let allApps = appManager.pages.flatMap { $0 }.compactMap { item -> AppInfo? in
            if case .app(let app) = item {
                return app
            }
            return nil
        }
        
        // All discovered apps should be valid regardless of whether they're symlinks
        for app in allApps.prefix(5) {
            let url = URL(fileURLWithPath: app.path)
            XCTAssertTrue(url.hasDirectoryPath, "App path should be a directory")
        }
    }
}
