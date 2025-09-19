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
                pages[draggedItem.page].move(fromOffsets: IndexSet([fromIndex]), toOffset: DropAnimationHelper.calculateMoveOffset(fromIndex: fromIndex, toIndex: toIndex))
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
    
    private func createFolder(with app1: AppInfo, and app2: AppInfo) {}
    
    private func addAppToFolder(_ app: AppInfo, targetFolder: Folder) {}
}
