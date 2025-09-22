import SwiftUI
import Foundation

struct FolderOverlayView: View {
    var appManager = AppManager.shared
    @Binding var pages: [[AppGridItem]]
    @Binding var selectedFolder: Folder?
    @Binding var isFolderOpen: Bool
    
    let iconSize: Double
    let columns: Int
    let dropDelay: Double
    
    var body: some View {
        Group {
            if selectedFolder != nil {
                ZStack {
                    Color.clear
                        .ignoresSafeArea(.all)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            commitChanges()
                        }
                    
                    FolderDetailView(
                        folder: Binding(
                            get: {  selectedFolder! },
                            set: { selectedFolder = $0 }
                        ),
                        iconSize: iconSize,
                        columns: columns,
                        dropDelay: dropDelay,
                        onSave: {
                            appManager.saveGridItems(items: pages.flatMap { $0 })
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
    
    private func commitChanges() {
        guard var selectedFolder = selectedFolder,
              let pageIndex = pages.firstIndex(where: { page in page.contains(where: { $0.id == selectedFolder.id }) }),
              let itemIndex = pages[pageIndex].firstIndex(where: { $0.id == selectedFolder.id })else { return }
        
        let newFolder = Folder(
            name: selectedFolder.name,
            page: selectedFolder.page,
            apps: selectedFolder.apps
        )
        
        selectedFolder = newFolder
        pages[pageIndex][itemIndex] = .folder(newFolder)
        
        appManager.saveGridItems(items: pages.flatMap { $0 })
        
        self.selectedFolder = nil
        isFolderOpen = false
    }
}
