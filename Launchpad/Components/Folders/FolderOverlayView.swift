import SwiftUI
import Foundation

struct FolderOverlayView: View {
    private let appManager = AppManager.shared
    @Binding var pages: [[AppGridItem]]
    @Binding var selectedFolder: Folder?
    @Binding var isFolderOpen: Bool
    
    let iconSize: Double
    let columns: Int
    let rows: Int
    let dropDelay: Double
    
    var body: some View {
        Group {
            if selectedFolder != nil {
                ZStack {
                    FolderDetailView(
                        folder: Binding(
                            get: { selectedFolder! },
                            set: { selectedFolder = $0 }
                        ),
                        iconSize: iconSize,
                        columns: columns,
                        dropDelay: dropDelay,
                        onSave: {
                            saveFolder()
                        },
                        onRemoveApp: { app in
                            addAppToPage(app)
                        }
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
        guard var selectedFolder = selectedFolder,
              let pageIndex = pages.firstIndex(where: { page in page.contains(where: { $0.id == selectedFolder.id }) }),
              let itemIndex = pages[pageIndex].firstIndex(where: { $0.id == selectedFolder.id })else { return }
        
        let newFolder = Folder(
            id: selectedFolder.id,
            name: selectedFolder.name,
            page: selectedFolder.page,
            apps: selectedFolder.apps
        )
        
        selectedFolder = newFolder
        pages[pageIndex][itemIndex] = .folder(newFolder)
        
        appManager.savePages(pages: pages)
        
        self.selectedFolder = nil
        isFolderOpen = false
    }
    
    private func addAppToPage(_ app: AppInfo) {
        guard let selectedFolder = selectedFolder,
              let pageIndex = pages.firstIndex(where: { page in page.contains(where: { $0.id == selectedFolder.id }) }) else { return }
        let updatedApp = AppInfo(id: app.id, name: app.name, icon: app.icon, path: app.path, page: pageIndex)
        pages[pageIndex].append(.app(updatedApp))
        
        handlePageOverflow(targetPageIndex: pageIndex)
        appManager.savePages(pages: pages)
    }
    
    private func handlePageOverflow(targetPageIndex: Int) {
        while pages[targetPageIndex].count > columns * rows {
            let overflowItem = pages[targetPageIndex].removeLast()
            
            let nextPageNumber = targetPageIndex + 1
            
            let updatedOverflowItem: AppGridItem
            switch overflowItem {
            case .app(let app):
                updatedOverflowItem = .app(AppInfo(id: app.id, name: app.name, icon: app.icon, path: app.path, page: nextPageNumber))
            case .folder(let folder):
                updatedOverflowItem = .folder(Folder(id: folder.id, name: folder.name, page: nextPageNumber, apps: folder.apps))
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

