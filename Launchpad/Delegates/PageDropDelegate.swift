import SwiftUI

struct PageDropDelegate: DropDelegate {
    private let appManager = AppManager.shared
    @Binding var pages: [[AppGridItem]]
    @Binding var draggedItem: AppGridItem?
    let targetPage: Int
    let appsPerPage: Int
    
    func performDrop(info: DropInfo) -> Bool {
        guard let draggedItem = draggedItem else {
            self.draggedItem = nil
            return false
        }
        
        // Always handle drop to empty page or different page
        if pages[targetPage].isEmpty || draggedItem.page != targetPage || shouldAddToEnd(draggedItem: draggedItem) {
            moveItemToEndOfPage(draggedItem: draggedItem)
        }
        
        self.draggedItem = nil
        appManager.pages = pages
        return true
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    private func shouldAddToEnd(draggedItem: AppGridItem) -> Bool {
        // Always add to end if page is empty
        if pages[targetPage].isEmpty {
            return true
        }
        
        // Add to end if the item is not already at the end of the current page
        guard let currentIndex = pages[targetPage].firstIndex(where: { $0.id == draggedItem.id }) else {
            return true
        }
        return currentIndex != pages[targetPage].count - 1
    }
    
    private func moveItemToEndOfPage(draggedItem: AppGridItem) {
        // Remove item from its current position
        if let currentPageIndex = pages.firstIndex(where: { page in
            page.contains(where: { $0.id == draggedItem.id })
        }),
        let currentItemIndex = pages[currentPageIndex].firstIndex(where: { $0.id == draggedItem.id }) {
            pages[currentPageIndex].remove(at: currentItemIndex)
        }
        
        // Create updated item with new page
        let updatedItem: AppGridItem
        switch draggedItem {
        case .app(let app):
            updatedItem = .app(AppInfo(name: app.name, icon: app.icon, path: app.path, page: targetPage))
        case .folder(let folder):
            updatedItem = .folder(Folder(name: folder.name, page: targetPage, apps: folder.apps))
        }
        
        // Add to end of target page
        pages[targetPage].append(updatedItem)
        self.draggedItem = updatedItem
        
        // Handle page overflow
        handlePageOverflow(targetPageIndex: targetPage)
    }
    
    private func handlePageOverflow(targetPageIndex: Int) {
        while pages[targetPageIndex].count > appsPerPage {
            let overflowItem = pages[targetPageIndex].removeLast()
            let nextPageNumber = targetPageIndex + 1
            
            let updatedOverflowItem: AppGridItem
            switch overflowItem {
            case .app(let app):
                updatedOverflowItem = .app(AppInfo(name: app.name, icon: app.icon, path: app.path, page: nextPageNumber))
            case .folder(let folder):
                updatedOverflowItem = .folder(Folder(name: folder.name, page: nextPageNumber, apps: folder.apps))
            }
            
            if nextPageNumber >= pages.count {
                pages.append([updatedOverflowItem])
            } else {
                pages[nextPageNumber].insert(updatedOverflowItem, at: 0)
                handlePageOverflow(targetPageIndex: nextPageNumber)
            }
        }
    }
}