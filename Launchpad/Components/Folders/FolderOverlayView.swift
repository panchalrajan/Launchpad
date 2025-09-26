import Foundation
import SwiftUI

struct FolderOverlayView: View {
   private let appManager = AppManager.shared
   @Binding var pages: [[AppGridItem]]
   @Binding var folder: Folder?
   let settings: LaunchpadSettings
   
   var body: some View {
      if folder != nil
      {
         FolderDetailView(
            folder: Binding( get: { folder! }, set: { folder = $0 }),
            settings: settings,
            onClose: saveFolder,
            onRemoveApp: addAppToPage
         )
         .animation(.interpolatingSpring(stiffness: 300, damping: 30), value: 1)
         .onAppear {
            withAnimation(.easeInOut(duration: 0.4)) {
            }
         }
      }
   }
   
   private func saveFolder() {
      guard let pageIndex = pages.firstIndex(where: { page in page.contains(where: { $0.id == folder!.id }) }),
            let itemIndex = pages[pageIndex].firstIndex(where: { $0.id == folder!.id })
      else {
         return
      }
      let newFolder = Folder(name: folder!.name, page: folder!.page, apps: folder!.apps)
      pages[pageIndex][itemIndex] = .folder(newFolder)
      appManager.pages = pages
      folder = nil
   }
   
   private func addAppToPage(app: AppInfo) {
      guard let pageIndex = pages.firstIndex(where: { page in page.contains(where: { $0.id == folder!.id }) })else { return }
      let updatedApp = AppInfo(name: app.name, icon: app.icon, path: app.path, page: pageIndex)
      pages[pageIndex].append(.app(updatedApp))
      handlePageOverflow(pageIndex: pageIndex)
      appManager.pages = pages
   }
   
   private func handlePageOverflow(pageIndex: Int) {
      while pages[pageIndex].count > settings.appsPerPage {
         let overflowItem = pages[pageIndex].removeLast()
         let nextPage = pageIndex + 1
         let updatedOverflowItem: AppGridItem
         switch overflowItem {
         case .app(let app):
            updatedOverflowItem = .app(AppInfo(name: app.name, icon: app.icon, path: app.path, page: nextPage))
         case .folder(let folder):
            updatedOverflowItem = .folder(Folder(name: folder.name, page: nextPage, apps: folder.apps))
         }
         if nextPage >= pages.count {
            pages.append([updatedOverflowItem])
         } else {
            pages[nextPage].insert(updatedOverflowItem, at: 0)
            handlePageOverflow(pageIndex: nextPage)
         }
      }
   }
}
