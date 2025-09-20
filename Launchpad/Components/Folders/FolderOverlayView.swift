import SwiftUI

struct FolderOverlayView: View {
    @Binding var pages: [[AppGridItem]]
    @Binding var selectedFolder: Folder?
    @Binding var isFolderOpen: Bool
    
    let iconSize: Double
    let columns: Int
    let dropDelay: Double
    
    var body: some View {
        Group {
            if isFolderOpen,
               let folder = selectedFolder,
               let pageIndex = pages.firstIndex(where: { page in page.contains(where: { $0.id == folder.id }) }),
               let itemIndex = pages[pageIndex].firstIndex(where: { $0.id == folder.id }),
               case .folder(let currentFolder) = pages[pageIndex][itemIndex] {
                ZStack {
                    Color.clear
                        .ignoresSafeArea(.all)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            dismissFolder()
                        }
                    
                    FolderDetailView(
                        folder: Binding(
                            get: { currentFolder },
                            set: { updatedFolder in
                                pages[pageIndex][itemIndex] = .folder(updatedFolder)
                                selectedFolder = updatedFolder
                            }
                        ),
                        iconSize: iconSize,
                        columns: columns,
                        dropDelay: dropDelay,
                        onDismiss: {
                            dismissFolder()
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
    
    private func dismissFolder() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isFolderOpen = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            selectedFolder = nil
            isFolderOpen = false
        }
    }
}