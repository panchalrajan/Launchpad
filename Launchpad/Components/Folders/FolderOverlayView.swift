import Foundation
import SwiftUI

struct FolderOverlayView: View {
    private let appManager = AppManager.shared
    @Binding var pages: [[AppGridItem]]
    @Binding var selectedFolder: Folder?
    @Binding var isFolderOpen: Bool
    let settings: LaunchpadSettings
    
    var body: some View {
        Group {
            if let folder = selectedFolder {
                ZStack {
                    FolderDetailView(
                        folder: Binding(
                            get: { folder },
                            set: { selectedFolder = $0 }
                        ),
                        settings: settings,
                        onClose: saveFolder,
                        onRemoveApp: addAppToPage
                    )
                    .scaleEffect(isFolderOpen ? 1.0 : 0.8)
                    .opacity(isFolderOpen ? 1.0 : 0.0)
                    .animation(.interpolatingSpring(stiffness: 300, damping: 30), value: isFolderOpen)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        isFolderOpen = true
                    }
                }
            }
        }
    }
    
    private func saveFolder() {
        guard let folder = selectedFolder,
              let pageIndex = pages.firstIndex(where: { page in page.contains(where: { $0.id == folder.id }) }),
              let itemIndex = pages[pageIndex].firstIndex(where: { $0.id == folder.id })
        else {
            selectedFolder = nil
            isFolderOpen = false
            return
        }
        let newFolder = Folder(name: folder.name, page: folder.page, apps: folder.apps)
        pages[pageIndex][itemIndex] = .folder(newFolder)
        appManager.pages = pages
        selectedFolder = nil
        isFolderOpen = false
    }
    
    private func addAppToPage(app: AppInfo) {
        guard let folder = selectedFolder,
              let pageIndex = pages.firstIndex(where: { page in page.contains(where: { $0.id == folder.id }) })
        else { return }
        let updatedApp = AppInfo(name: app.name, icon: app.icon, path: app.path, page: pageIndex)
        pages[pageIndex].append(.app(updatedApp))
        handlePageOverflow(pageIndex)
        appManager.pages = pages
    }
    
    private func handlePageOverflow(_ pageIndex: Int) {
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
                handlePageOverflow(nextPage)
            }
        }
    }
}
