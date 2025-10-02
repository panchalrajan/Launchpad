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

      moveItemToEndOfPage(draggedItem: draggedItem)

      self.draggedItem = nil
      return true
   }

   func dropUpdated(info: DropInfo) -> DropProposal? {
      return DropProposal(operation: .move)
   }

   private func moveItemToEndOfPage(draggedItem: AppGridItem) {
      guard let (currentPageIndex, currentItemIndex) = findItemLocation(item: draggedItem) else { return }

      pages[currentPageIndex].remove(at: currentItemIndex)
      pages[targetPage].append(updateItemPage(item: draggedItem, page: targetPage))

      handlePageOverflow(targetPageIndex: targetPage)
   }

   private func findItemLocation(item: AppGridItem) -> (pageIndex: Int, itemIndex: Int)? {
      for (pageIndex, page) in pages.enumerated() {
         if let itemIndex = page.firstIndex(where: { $0.id == item.id }) {
            return (pageIndex, itemIndex)
         }
      }
      return nil
   }

   private func updateItemPage(item: AppGridItem, page: Int) -> AppGridItem {
      return item.withUpdatedPage(page)
   }

   private func handlePageOverflow(targetPageIndex: Int) {
      while pages[targetPageIndex].count > appsPerPage {
         let overflowItem = pages[targetPageIndex].removeLast()
         let nextPageNumber = targetPageIndex + 1

         let updatedOverflowItem = overflowItem.withUpdatedPage(nextPageNumber)

         if nextPageNumber >= pages.count {
            pages.append([updatedOverflowItem])
         } else {
            pages[nextPageNumber].insert(updatedOverflowItem, at: 0)
            handlePageOverflow(targetPageIndex: nextPageNumber)
         }
      }
   }
}
