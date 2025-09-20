import SwiftUI
import Foundation

struct FolderOverlayView: View {
    @Binding var pages: [[AppGridItem]]
    @Binding var selectedFolder: Folder?
    @Binding var isFolderOpen: Bool
    
    let iconSize: Double
    let columns: Int
    let dropDelay: Double
    
    var body: some View {
        Group {
            if isFolderOpen {
                ZStack {
                    Color.clear
                        .ignoresSafeArea(.all)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if let folder = selectedFolder,
                               let pageIndex = pages.firstIndex(where: { page in page.contains(where: { $0.id == folder.id }) }),
                               let itemIndex = pages[pageIndex].firstIndex(where: { $0.id == folder.id }) {
                                commitChanges(pageIndex: pageIndex, itemIndex: itemIndex)
                            }
                            dismissFolder()
                        }
                    
                    if let folder = selectedFolder,
                       let pageIndex = pages.firstIndex(where: { page in page.contains(where: { $0.id == folder.id }) }),
                       let itemIndex = pages[pageIndex].firstIndex(where: { $0.id == folder.id }) {
                        FolderDetailView(
                            folder: Binding(
                                get: {  selectedFolder! },
                                set: { selectedFolder = $0 }
                            ),
                            iconSize: iconSize,
                            columns: columns,
                            dropDelay: dropDelay,
                            onDismiss: {
                                commitChanges(pageIndex: pageIndex, itemIndex: itemIndex)
                                dismissFolder()
                            }
                        )
                        .scaleEffect(isFolderOpen ? 1.0 : 0.8)
                        .opacity(isFolderOpen ? 1.0 : 0.0)
                        .animation(.interpolatingSpring(stiffness: 300, damping: 30), value: isFolderOpen)
                        
                    }
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        isFolderOpen = true
                    }
                }
            }
        }
    }
    
    private func commitChanges(pageIndex: Int, itemIndex: Int) {
        guard var selectedFolder = selectedFolder else { return }
        
        let newFolder = Folder(
            name: selectedFolder.name,
            page: selectedFolder.page,
            apps: selectedFolder.apps
        )
        
        selectedFolder = newFolder
        pages[pageIndex][itemIndex] = .folder(newFolder)
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name("SaveGridItems"), object: nil)
        }
        
        self.selectedFolder = nil
    }
    
    private func dismissFolder() {
        NotificationCenter.default.post(name: NSNotification.Name("SaveGridItems"), object: nil)
        
        withAnimation(.easeInOut(duration: 0.3)) {
            isFolderOpen = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            selectedFolder = nil
            isFolderOpen = false
            self.selectedFolder = nil
        }
    }
}
