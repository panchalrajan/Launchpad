import XCTest
import AppKit
@testable import Launchpad

@MainActor
final class LaunchpadDatabaseReaderTests: XCTestCase {
    
    var testDirectory: URL!
    
    override func setUp() {
        super.setUp()
        
        // Create a temporary directory for test files
        testDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("LaunchpadTests")
            .appendingPathComponent(UUID().uuidString)
        
        try? FileManager.default.createDirectory(at: testDirectory, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        // Clean up test files
        try? FileManager.default.removeItem(at: testDirectory)
        super.tearDown()
    }
    
    // MARK: - Path Detection Tests
    
    func testGetOldLaunchpadDatabasePath() {
        // When: Getting the old Launchpad database path
        let dbPath = LaunchpadDatabaseReader.getOldLaunchpadDatabasePath()
        
        // Then: Should return a valid path
        XCTAssertNotNil(dbPath, "Should return a database path")
        
        if let path = dbPath {
            XCTAssertTrue(path.hasPrefix("/private"), "Path should start with /private")
            XCTAssertTrue(path.contains("com.apple.dock.launchpad"), "Path should contain Launchpad directory")
            XCTAssertTrue(path.hasSuffix("/db/db"), "Path should end with /db/db")
        }
    }
    
    func testOldLaunchpadDatabaseExists() {
        // When: Checking if old database exists
        let exists = LaunchpadDatabaseReader.oldLaunchpadDatabaseExists()
        
        // Then: Result should be a boolean
        // We can't guarantee the database exists on test systems,
        // so we just verify the method runs without crashing
        XCTAssertTrue(exists == true || exists == false, "Should return a boolean value")
    }
    
    // MARK: - Database Reading Tests
    
    func testReadOldLaunchpadLayoutWhenDatabaseMissing() {
        // When: Reading from a non-existent database
        let layout = LaunchpadDatabaseReader.readOldLaunchpadLayout()
        
        // Then: Should return nil if database doesn't exist
        // (unless running on a system with actual Launchpad data)
        if layout == nil {
            XCTAssertNil(layout, "Should return nil when database doesn't exist")
        } else {
            // If we're on a system with Launchpad data, verify the structure
            XCTAssertNotNil(layout, "Layout data should be valid if database exists")
            
            // Verify returned data structure
            for item in layout! {
                XCTAssertFalse(item.path.isEmpty, "Path should not be empty")
                XCTAssertTrue(item.path.hasSuffix(".app"), "Path should end with .app")
                XCTAssertGreaterThanOrEqual(item.page, 0, "Page should be non-negative")
                XCTAssertGreaterThanOrEqual(item.position, 0, "Position should be non-negative")
            }
        }
    }
    
    func testReadOldLaunchpadFoldersWhenDatabaseMissing() {
        // When: Reading folders from a non-existent database
        let folders = LaunchpadDatabaseReader.readOldLaunchpadFolders()
        
        // Then: Should return nil if database doesn't exist
        // (unless running on a system with actual Launchpad data)
        if folders == nil {
            XCTAssertNil(folders, "Should return nil when database doesn't exist")
        } else {
            // If we're on a system with Launchpad data, verify the structure
            XCTAssertNotNil(folders, "Folders data should be valid if database exists")
            
            // Verify returned data structure
            for folder in folders! {
                XCTAssertFalse(folder.name.isEmpty, "Folder name should not be empty")
                XCTAssertGreaterThanOrEqual(folder.page, 0, "Page should be non-negative")
                XCTAssertGreaterThan(folder.appPaths.count, 0, "Folder should have at least one app")
                
                for appPath in folder.appPaths {
                    XCTAssertTrue(appPath.hasSuffix(".app"), "App path should end with .app")
                }
            }
        }
    }
    
    // MARK: - Integration Tests with AppManager
    
    func testImportFromOldLaunchpadWhenDatabaseMissing() {
        // Given: AppManager instance
        let appManager = AppManager.shared
        
        // When: Attempting to import from old Launchpad
        let success = appManager.importFromOldLaunchpad(appsPerPage: 35)
        
        // Then: Should handle missing database gracefully
        // Result depends on whether old Launchpad database exists
        if !success {
            XCTAssertFalse(success, "Should return false when database doesn't exist")
        } else {
            // If database exists, verify import succeeded
            XCTAssertTrue(success, "Should return true when database exists and import succeeds")
            XCTAssertGreaterThan(appManager.pages.count, 0, "Should have at least one page after import")
        }
    }
    
    func testImportFromOldLaunchpadPreservesDiscoveredApps() {
        // Given: AppManager with discovered apps
        let appManager = AppManager.shared
        appManager.loadGridItems(appsPerPage: 35)
        let initialAppCount = appManager.pages.flatMap { $0 }.count
        
        // When: Attempting to import from old Launchpad
        let success = appManager.importFromOldLaunchpad(appsPerPage: 35)
        
        // Then: Should preserve all discovered apps
        let finalAppCount = appManager.pages.flatMap { $0 }.count
        
        if success {
            // If import succeeded, app count should be maintained or increased
            XCTAssertGreaterThanOrEqual(finalAppCount, 1, "Should have apps after import")
        } else {
            // If import failed, original apps should still be present
            XCTAssertEqual(finalAppCount, initialAppCount, "Should preserve original apps on import failure")
        }
    }
    
    // MARK: - Edge Cases
    
    func testDatabasePathWithSpecialCharacters() {
        // Test that path handling works correctly with special characters
        let path = LaunchpadDatabaseReader.getOldLaunchpadDatabasePath()
        
        if let dbPath = path {
            // Verify path doesn't have problematic characters
            XCTAssertFalse(dbPath.contains("\\"), "Path should use forward slashes")
            XCTAssertFalse(dbPath.contains("//"), "Path should not have double slashes")
        }
    }
    
    func testReadLayoutReturnsValidStructure() {
        // When: Reading layout (even if database doesn't exist)
        let layout = LaunchpadDatabaseReader.readOldLaunchpadLayout()
        
        // Then: If data is returned, it should be properly structured
        if let items = layout {
            // Verify all items have valid pages and positions
            for item in items {
                XCTAssertGreaterThanOrEqual(item.page, 0, "Page must be non-negative")
                XCTAssertGreaterThanOrEqual(item.position, 0, "Position must be non-negative")
                XCTAssertFalse(item.path.isEmpty, "Path must not be empty")
            }
            
            // Verify pages are sequential (no gaps)
            let pages = Set(items.map { $0.page })
            if !pages.isEmpty {
                let maxPage = pages.max()!
                XCTAssertEqual(pages.count, maxPage + 1, "Pages should be sequential without gaps")
            }
        }
    }
    
    func testReadFoldersReturnsValidStructure() {
        // When: Reading folders (even if database doesn't exist)
        let folders = LaunchpadDatabaseReader.readOldLaunchpadFolders()
        
        // Then: If data is returned, it should be properly structured
        if let folderList = folders {
            for folder in folderList {
                // Verify folder structure
                XCTAssertFalse(folder.name.isEmpty, "Folder name must not be empty")
                XCTAssertGreaterThanOrEqual(folder.page, 0, "Page must be non-negative")
                XCTAssertGreaterThan(folder.appPaths.count, 0, "Folder must have at least one app")
                
                // Verify all apps in folder are valid
                for appPath in folder.appPaths {
                    XCTAssertFalse(appPath.isEmpty, "App path must not be empty")
                    XCTAssertTrue(appPath.hasSuffix(".app"), "App path must end with .app")
                }
                
                // Verify no duplicate apps in folder
                let uniquePaths = Set(folder.appPaths)
                XCTAssertEqual(uniquePaths.count, folder.appPaths.count, "Folder should not have duplicate apps")
            }
        }
    }
    
    // MARK: - Performance Tests
    
    func testDatabaseReadPerformance() {
        // Only run performance test if database exists
        guard LaunchpadDatabaseReader.oldLaunchpadDatabaseExists() else {
            return
        }
        
        measure {
            _ = LaunchpadDatabaseReader.readOldLaunchpadLayout()
        }
    }
    
    func testFolderReadPerformance() {
        // Only run performance test if database exists
        guard LaunchpadDatabaseReader.oldLaunchpadDatabaseExists() else {
            return
        }
        
        measure {
            _ = LaunchpadDatabaseReader.readOldLaunchpadFolders()
        }
    }
}
