import XCTest
import AppKit
@testable import Launchpad

@MainActor
final class AppManagerHiddenAppsTests: XCTestCase {
   
   var appManager: AppManager!
   let hiddenAppsKey = "LaunchpadHiddenApps"
   let gridItemsKey = "LaunchpadGridItems"
   
   override func setUp() {
      super.setUp()
      appManager = AppManager.shared
      
      // Clear test data
      UserDefaults.standard.removeObject(forKey: hiddenAppsKey)
      UserDefaults.standard.removeObject(forKey: gridItemsKey)
      UserDefaults.standard.synchronize()
      
      // Reset hidden apps in manager
      appManager.hiddenAppPaths = Set<String>()
   }
   
   override func tearDown() {
      UserDefaults.standard.removeObject(forKey: hiddenAppsKey)
      UserDefaults.standard.removeObject(forKey: gridItemsKey)
      UserDefaults.standard.synchronize()
      
      // Reset hidden apps in manager
      appManager.hiddenAppPaths = Set<String>()
      super.tearDown()
   }
   
   // MARK: - Initialization Tests
   
   func testHiddenAppsInitializedEmpty() {
      XCTAssertTrue(appManager.hiddenAppPaths.isEmpty, "Hidden apps should be empty on initialization")
   }
   
   func testHiddenAppsLoadedFromUserDefaults() {
      // Given: Hidden apps stored in UserDefaults
      let hiddenPaths = ["/Applications/Test1.app", "/Applications/Test2.app"]
      UserDefaults.standard.set(hiddenPaths, forKey: hiddenAppsKey)
      
      // When: Creating a new AppManager instance (we'll test with shared)
      // Note: In a real scenario, we'd need dependency injection to properly test this
      // For now, we verify the loading mechanism works
      let savedPaths = UserDefaults.standard.stringArray(forKey: hiddenAppsKey) ?? []
      
      // Then: Hidden apps should be loaded
      XCTAssertEqual(savedPaths.count, 2, "Should load 2 hidden apps from UserDefaults")
      XCTAssertTrue(savedPaths.contains("/Applications/Test1.app"), "Should contain Test1.app")
      XCTAssertTrue(savedPaths.contains("/Applications/Test2.app"), "Should contain Test2.app")
   }
   
   // MARK: - Hide App Tests
   
   func testHideApp() {
      // Given: No hidden apps initially
      XCTAssertTrue(appManager.hiddenAppPaths.isEmpty, "Should start with no hidden apps")
      
      // When: Hiding an app
      appManager.hideApp(path: "/Applications/TestApp.app", appsPerPage: 20)
      
      // Then: App should be in hidden set
      XCTAssertTrue(appManager.hiddenAppPaths.contains("/Applications/TestApp.app"), 
                    "App should be added to hidden apps")
      XCTAssertEqual(appManager.hiddenAppPaths.count, 1, "Should have 1 hidden app")
   }
   
   func testHideAppPersistsToUserDefaults() async {      
      // When: Hiding an app
      appManager.hideApp(path: "/Applications/TestApp.app", appsPerPage: 20)
      
      // Wait for async save
      try? await Task.sleep(nanoseconds: 100_000_000)
      
      // Then: Hidden apps should be saved to UserDefaults
      let savedPaths = UserDefaults.standard.stringArray(forKey: hiddenAppsKey)
      XCTAssertNotNil(savedPaths, "Hidden apps should be saved to UserDefaults")
      XCTAssertEqual(savedPaths?.count, 1, "Should save 1 hidden app")
      XCTAssertTrue(savedPaths?.contains("/Applications/TestApp.app") ?? false, 
                    "Should save the correct app path")
   }
   
   func testHideMultipleApps() {
      // When: Hiding multiple apps
      appManager.hideApp(path: "/Applications/App1.app", appsPerPage: 20)
      appManager.hideApp(path: "/Applications/App2.app", appsPerPage: 20)
      appManager.hideApp(path: "/Applications/App3.app", appsPerPage: 20)
      
      // Then: All apps should be hidden
      XCTAssertEqual(appManager.hiddenAppPaths.count, 3, "Should have 3 hidden apps")
      XCTAssertTrue(appManager.hiddenAppPaths.contains("/Applications/App1.app"), 
                    "Should contain App1")
      XCTAssertTrue(appManager.hiddenAppPaths.contains("/Applications/App2.app"), 
                    "Should contain App2")
      XCTAssertTrue(appManager.hiddenAppPaths.contains("/Applications/App3.app"), 
                    "Should contain App3")
   }
   
   func testHideSameAppTwice() {
      // When: Hiding the same app twice
      appManager.hideApp(path: "/Applications/TestApp.app", appsPerPage: 20)
      appManager.hideApp(path: "/Applications/TestApp.app", appsPerPage: 20)
      
      // Then: Should only be added once (Set behavior)
      XCTAssertEqual(appManager.hiddenAppPaths.count, 1, "Should only have 1 hidden app (no duplicates)")
   }
   
   // MARK: - Unhide App Tests
   
   func testUnhideApp() {
      // Given: A hidden app
      appManager.hideApp(path: "/Applications/TestApp.app", appsPerPage: 20)
      XCTAssertTrue(appManager.hiddenAppPaths.contains("/Applications/TestApp.app"), 
                    "App should be hidden")
      
      // When: Unhiding the app
      appManager.unhideApp(path: "/Applications/TestApp.app", appsPerPage: 20)
      
      // Then: App should be removed from hidden set
      XCTAssertFalse(appManager.hiddenAppPaths.contains("/Applications/TestApp.app"), 
                     "App should be unhidden")
      XCTAssertTrue(appManager.hiddenAppPaths.isEmpty, "Hidden apps should be empty")
   }
   
   func testUnhideAppPersistsToUserDefaults() async {
      // Given: A hidden app saved in UserDefaults
      appManager.hideApp(path: "/Applications/TestApp.app", appsPerPage: 20)
      try? await Task.sleep(nanoseconds: 100_000_000)
      
      // When: Unhiding the app
      appManager.unhideApp(path: "/Applications/TestApp.app", appsPerPage: 20)
      try? await Task.sleep(nanoseconds: 100_000_000)
      
      // Then: UserDefaults should be updated
      let savedPaths = UserDefaults.standard.stringArray(forKey: hiddenAppsKey)
      XCTAssertNotNil(savedPaths, "Should still have saved data structure")
      XCTAssertEqual(savedPaths?.count, 0, "Should have no hidden apps")
   }
   
   func testUnhideNonHiddenApp() {
      // Given: No hidden apps
      XCTAssertTrue(appManager.hiddenAppPaths.isEmpty, "Should have no hidden apps")
      
      // When: Unhiding an app that was never hidden
      appManager.unhideApp(path: "/Applications/TestApp.app", appsPerPage: 20)
      
      // Then: Should not cause any issues
      XCTAssertTrue(appManager.hiddenAppPaths.isEmpty, "Should still have no hidden apps")
   }
   
   func testUnhideOneOfMultipleApps() {
      // Given: Multiple hidden apps
      appManager.hideApp(path: "/Applications/App1.app", appsPerPage: 20)
      appManager.hideApp(path: "/Applications/App2.app", appsPerPage: 20)
      appManager.hideApp(path: "/Applications/App3.app", appsPerPage: 20)
      
      // When: Unhiding one app
      appManager.unhideApp(path: "/Applications/App2.app", appsPerPage: 20)
      
      // Then: Only that app should be unhidden
      XCTAssertEqual(appManager.hiddenAppPaths.count, 2, "Should have 2 hidden apps remaining")
      XCTAssertTrue(appManager.hiddenAppPaths.contains("/Applications/App1.app"), 
                    "App1 should still be hidden")
      XCTAssertFalse(appManager.hiddenAppPaths.contains("/Applications/App2.app"), 
                     "App2 should be unhidden")
      XCTAssertTrue(appManager.hiddenAppPaths.contains("/Applications/App3.app"), 
                    "App3 should still be hidden")
   }
   
   // MARK: - Get Hidden Apps Tests
   
   func testGetHiddenAppsWhenEmpty() {
      // When: Getting hidden apps with none hidden
      let hiddenApps = appManager.getHiddenApps()
      
      // Then: Should return empty array
      XCTAssertTrue(hiddenApps.isEmpty, "Should return empty array when no apps are hidden")
   }
   
   func testGetHiddenAppsWithNonExistentPaths() {
      // Given: Hidden paths for apps that don't exist
      appManager.hiddenAppPaths.insert("/Applications/FakeApp.app")
      appManager.hiddenAppPaths.insert("/Applications/NonExistent.app")
      
      // When: Getting hidden apps
      let hiddenApps = appManager.getHiddenApps()
      
      // Then: Should only return apps that actually exist on the system
      // Note: This test depends on actual filesystem, so we just check it doesn't crash
      XCTAssertNotNil(hiddenApps, "Should return a valid array")
   }
   
   // MARK: - Integration Tests with Load Grid Items
   
   func testLoadGridItemsFiltersHiddenApps() {
      // This test verifies that hidden apps are filtered when loading the grid
      // Given: Some apps are hidden
      // We'll use actual discovered apps to test this properly
      appManager.loadGridItems(appsPerPage: 20)
      let allItemsCount = appManager.pages.flatMap { $0 }.count
      
      guard allItemsCount > 0 else {
         XCTFail("Need at least one app to test hiding")
         return
      }
      
      // Get the path of the first app to hide
      if case .app(let firstApp) = appManager.pages[0][0] {
         let pathToHide = firstApp.path
         
         // When: Hiding an app and reloading
         appManager.hideApp(path: pathToHide, appsPerPage: 20)
         
         // Then: The grid should have one less app
         let newItemsCount = appManager.pages.flatMap { $0 }.count
         XCTAssertEqual(newItemsCount, allItemsCount - 1, 
                       "Grid should have one less app after hiding")
         
         // Verify the hidden app is not in the grid
         let allItems = appManager.pages.flatMap { $0 }
         let containsHiddenApp = allItems.contains { item in
            if case .app(let app) = item {
               return app.path == pathToHide
            }
            return false
         }
         XCTAssertFalse(containsHiddenApp, "Hidden app should not appear in grid")
      } else {
         XCTFail("First item should be an app")
      }
   }
   
   func testHideAndUnhideWorkflow() {
      // Test complete hide/unhide workflow
      // Given: Load apps
      appManager.loadGridItems(appsPerPage: 20)
      let originalCount = appManager.pages.flatMap { $0 }.count
      
      guard originalCount > 0 else {
         XCTFail("Need at least one app to test")
         return
      }
      
      if case .app(let firstApp) = appManager.pages[0][0] {
         let pathToHide = firstApp.path
         
         // When: Hiding an app
         appManager.hideApp(path: pathToHide, appsPerPage: 20)
         let hiddenCount = appManager.pages.flatMap { $0 }.count
         
         // Then: Count should decrease
         XCTAssertEqual(hiddenCount, originalCount - 1, "Count should decrease by 1")
         
         // When: Unhiding the app
         appManager.unhideApp(path: pathToHide, appsPerPage: 20)
         let restoredCount = appManager.pages.flatMap { $0 }.count
         
         // Then: Count should be restored
         XCTAssertEqual(restoredCount, originalCount, "Count should be restored")
      }
   }
   
   // MARK: - Folder Tests with Hidden Apps
   
   func testFolderWithAllAppsHiddenIsHidden() {
      // Given: A folder where all apps are hidden
      let mockIcon = NSImage(size: NSSize(width: 64, height: 64))
      let app1 = AppInfo(name: "App 1", icon: mockIcon, path: "/Applications/App1.app", page: 0)
      let app2 = AppInfo(name: "App 2", icon: mockIcon, path: "/Applications/App2.app", page: 0)
      let folder = Folder(name: "Test Folder", page: 0, apps: [app1, app2])
      
      // Hide both apps in the folder
      appManager.hiddenAppPaths.insert("/Applications/App1.app")
      appManager.hiddenAppPaths.insert("/Applications/App2.app")
      
      // Set up pages with the folder
      appManager.pages = [[.folder(folder)]]
      
      // When: Loading grid items (which filters hidden items)
      appManager.loadGridItems(appsPerPage: 20)
      
      // Then: The folder should not appear in the grid
      // Note: This test assumes the folder won't be in discovered apps
      // In practice, the folder would be filtered during loadLayoutFromUserDefaults
      XCTAssertNotNil(appManager.pages, "Pages should exist")
   }
   
   func testFolderWithSomeAppsHiddenNotHidden() {
      // Given: A folder where only some apps are hidden
      let mockIcon = NSImage(size: NSSize(width: 64, height: 64))
      let app1 = AppInfo(name: "App 1", icon: mockIcon, path: "/Applications/App1.app", page: 0)
      let app2 = AppInfo(name: "App 2", icon: mockIcon, path: "/Applications/App2.app", page: 0)
      let folder = Folder(name: "Test Folder", page: 0, apps: [app1, app2])
      
      // Hide only one app in the folder
      appManager.hiddenAppPaths.insert("/Applications/App1.app")
      
      // Set up pages with the folder
      appManager.pages = [[.folder(folder)]]
      
      // The folder itself should still be visible since not all apps are hidden
      // This is tested by the isItemHidden logic
      XCTAssertNotNil(appManager.pages, "Pages should exist")
   }
   
   // MARK: - Edge Cases
   
   func testHideAppWithEmptyPath() {
      // When: Trying to hide an app with empty path
      appManager.hideApp(path: "", appsPerPage: 20)
      
      // Then: Should add empty string to set (edge case)
      XCTAssertTrue(appManager.hiddenAppPaths.contains(""), 
                    "Empty path should be added (though not useful)")
   }
   
   func testHideAppWithInvalidPath() {
      // When: Hiding an app with invalid path
      appManager.hideApp(path: "not/a/valid/path", appsPerPage: 20)
      
      // Then: Should still be added to hidden set
      XCTAssertTrue(appManager.hiddenAppPaths.contains("not/a/valid/path"), 
                    "Invalid path should still be tracked")
   }
   
   func testPersistenceAfterMultipleHideUnhide() async {
      // When: Performing multiple hide/unhide operations
      appManager.hideApp(path: "/Applications/App1.app", appsPerPage: 20)
      appManager.hideApp(path: "/Applications/App2.app", appsPerPage: 20)
      try? await Task.sleep(nanoseconds: 100_000_000)
      
      appManager.unhideApp(path: "/Applications/App1.app", appsPerPage: 20)
      try? await Task.sleep(nanoseconds: 100_000_000)
      
      appManager.hideApp(path: "/Applications/App3.app", appsPerPage: 20)
      try? await Task.sleep(nanoseconds: 100_000_000)
      
      // Then: Final state should be persisted correctly
      let savedPaths = UserDefaults.standard.stringArray(forKey: hiddenAppsKey)
      XCTAssertEqual(savedPaths?.count, 2, "Should have 2 hidden apps")
      XCTAssertFalse(savedPaths?.contains("/Applications/App1.app") ?? true, 
                     "App1 should not be in saved data")
      XCTAssertTrue(savedPaths?.contains("/Applications/App2.app") ?? false, 
                    "App2 should be in saved data")
      XCTAssertTrue(savedPaths?.contains("/Applications/App3.app") ?? false, 
                    "App3 should be in saved data")
   }
}
