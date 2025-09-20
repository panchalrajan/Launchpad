import SwiftUI

struct ItemDropDelegate: DropDelegate {
    let dropDelay: Double
    let targetItem: AppGridItem
    let targetPage: Int
    let appsPerPage: Int
    
    @Binding var pages: [[AppGridItem]]
    @Binding var draggedItem: AppGridItem?
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = draggedItem else {
            return
        }
        
        // Find the actual array indices for the source and target pages
        guard let fromIndex = pages[draggedItem.page].firstIndex(where: { $0.id == draggedItem.id }),
              let toIndex = pages[targetItem.page].firstIndex(where: { $0.id == targetItem.id }) else {
            return
        }
        
        if draggedItem.page == targetItem.page {
            
            DropAnimationHelper.performDelayedMove(delay: dropDelay) {
                if(self.draggedItem != nil) {
                    pages[draggedItem.page].move(fromOffsets: IndexSet([fromIndex]), toOffset: DropAnimationHelper.calculateMoveOffset(fromIndex: fromIndex, toIndex: toIndex))
                }
            }
        } else {
            let item = pages[draggedItem.page][fromIndex]
            
            var updatedItem = item
            switch updatedItem {
            case .app(let app):
                updatedItem = .app(AppInfo(name: app.name, icon: app.icon, path: app.path, page: targetPage))
            case .folder(let folder):
                updatedItem = .folder(Folder(name: folder.name, page: targetPage, apps: folder.apps))
            }
            
            pages[targetItem.page].insert(updatedItem, at: toIndex)
            pages[draggedItem.page].remove(at: fromIndex)
            
            // Update the draggedItem binding to reflect the new value
            self.draggedItem = updatedItem
            
            // Check if target page now exceeds the limit
            handlePageOverflow(targetPageIndex: targetItem.page)
        }
    }
    
    private func handlePageOverflow(targetPageIndex: Int) {
        // If target page exceeds limit, move overflow items to next pages
        while pages[targetPageIndex].count > appsPerPage {
            let overflowItem = pages[targetPageIndex].removeLast()
            
            // Find the next page number to move the item to
            let nextPageNumber = targetPageIndex + 1
            
            // Update the item's page attribute
            var updatedOverflowItem = overflowItem
            switch overflowItem {
            case .app(let app):
                updatedOverflowItem = .app(AppInfo(name: app.name, icon: app.icon, path: app.path, page: nextPageNumber))
            case .folder(let folder):
                updatedOverflowItem = .folder(Folder(name: folder.name, page: nextPageNumber, apps: folder.apps))
            }
            
            // Ensure we have a page at the next index
            if nextPageNumber >= pages.count {
                pages.append([updatedOverflowItem])
            } else {
                // Insert at the beginning of the next page
                pages[nextPageNumber].insert(updatedOverflowItem, at: 0)
                // Recursively handle overflow on the next page
                handlePageOverflow(targetPageIndex: nextPageNumber)
            }
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        
        guard let draggedItem = draggedItem else {
            self.draggedItem = nil
            return true
        }
        
        if draggedItem.id != targetItem.id {
            switch (draggedItem, targetItem) {
            case (.app(let draggedApp), .app(let targetApp)):
                createFolder(with: draggedApp, and: targetApp)
            case (.app(let draggedApp), .folder(let targetFolder)):
                addAppToFolder(draggedApp, targetFolder: targetFolder)
            default:
                break
            }
        }
        
        self.draggedItem = nil
        return true
    }
    
    private func createFolder(with app1: AppInfo, and app2: AppInfo) {
        // Find the indices of both apps
        guard let app1Index = pages[app1.page].firstIndex(where: {
            if case .app(let app) = $0 { return app.id == app1.id }
            return false
        }),
              let app2Index = pages[app2.page].firstIndex(where: {
                  if case .app(let app) = $0 { return app.id == app2.id }
                  return false
              }) else { return }
        
        // Create the new folder
        let folderName = "New Folder"
        let folder = Folder(name: folderName, page: app2.page, apps: [app1, app2])
        let folderItem = AppGridItem.folder(folder)
        let adjustedTargetIndex = app1Index < app2Index ? app2Index - 1 : app2Index
        // Remove both apps from their current positions
        // Remove in descending order to maintain correct indices
        if app1.page == app2.page {
            let indices = [app1Index, app2Index].sorted(by: >)
            for index in indices {
                pages[app1.page].remove(at: index)
            }
            // Insert folder at the position of the target app (app2)
            let insertIndex = min(adjustedTargetIndex, pages[app2.page].count)
            pages[app2.page].insert(folderItem, at: insertIndex)
        } else {
            // Apps are on different pages
            pages[app1.page].remove(at: app1Index)
            pages[app2.page].remove(at: app2Index)
            
            // Insert folder at the position of the target app (app2)
            let insertIndex = min(app2Index, pages[app2.page].count)
            pages[app2.page].insert(folderItem, at: insertIndex)
        }
        
        self.draggedItem = nil
    }
    
    private func addAppToFolder(_ app: AppInfo, targetFolder: Folder) {
        // Find the indices of the app and folder
        guard let appIndex = pages[app.page].firstIndex(where: {
            if case .app(let appInfo) = $0 { return appInfo.id == app.id }
            return false
        }),
              let folderIndex = pages[targetFolder.page].firstIndex(where: {
                  if case .folder(let folderInfo) = $0 { return folderInfo.id == targetFolder.id }
                  return false
              }) else { return }
        
        // Create updated folder with the new app
        var updatedApps = targetFolder.apps
        updatedApps.append(app)
        let updatedFolder = Folder(name: targetFolder.name, page: targetFolder.page, apps: updatedApps)
        let updatedFolderItem = AppGridItem.folder(updatedFolder)
        
        // Remove the app from its current position
        pages[app.page].remove(at: appIndex)
        
        // Update the folder in its position
        pages[targetFolder.page][folderIndex] = updatedFolderItem
        
        self.draggedItem = nil
    }
}
