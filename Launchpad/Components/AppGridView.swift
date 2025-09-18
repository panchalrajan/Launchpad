import SwiftUI
import AppKit

struct AppGridView: View {
    @Binding var items: [AppGridItem]
    let columns: Int
    let iconSize: Double
    let dropDelay: Double
    @Binding var isFolderOpen: Bool
    @State private var isVisible = false
    @State private var draggedItem: AppGridItem?
    @State private var selectedFolder: Folder?
    
    var body: some View {
        GeometryReader { geo in
            let layout = LayoutMetrics(size: geo.size, columns: columns, iconSize: iconSize)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyVGrid(
                    columns: GridLayoutUtility.createGridColumns(count: columns, cellWidth: layout.cellWidth, spacing: layout.spacing),
                    spacing: layout.spacing) {
                        ForEach(items) { item in
                            AppGridItemView(
                                item: item,
                                layout: layout,
                                isDragged: draggedItem?.id == item.id
                            )
                            .onTapGesture {
                                handleItemTap(item)
                            }
                            .onDrag {
                                draggedItem = item
                                return NSItemProvider(object: item.id.uuidString as NSString)
                            }
                            .onDrop(of: [.text], delegate: GridDropDelegate(
                                dropDelay: dropDelay,
                                targetItem: item,
                                items: $items,
                                draggedItem: $draggedItem
                            ))
                        }
                    }
                    .padding(.horizontal, layout.hPadding)
                    .padding(.vertical, layout.vPadding)
            }
        }
        .fadeInScale(isVisible: isVisible)
        .onAppear { isVisible = true }
        .onDisappear { isVisible = false }
        .overlay {
            if isFolderOpen,
               let folder = selectedFolder,
               let index = items.firstIndex(where: { $0.id == folder.id }),
               case .folder(let currentFolder) = items[index] {
                ZStack {
                    Color.clear
                        .ignoresSafeArea(.all)
                        .onTapGesture {
                            selectedFolder = nil
                            isFolderOpen = false
                        }
                    
                    VisualEffectView(material: .fullScreenUI, blendingMode: .behindWindow)
                        .opacity(0.8)
                        .ignoresSafeArea(.all)
                        .allowsHitTesting(false)
                    
                    FolderDetailView(
                        folder: Binding(
                            get: { currentFolder },
                            set: { updatedFolder in
                                items[index] = .folder(updatedFolder)
                                selectedFolder = updatedFolder
                            }
                        ),
                        iconSize: iconSize,
                        columns: columns,
                        dropDelay: dropDelay,
                        onDismiss: {
                            selectedFolder = nil
                            isFolderOpen = false
                        }
                    )
                }
            }
        }
    }
    
    private func handleItemTap(_ item: AppGridItem) {
        switch item {
        case .app(let app):
            return
        case .folder(let folder):
            selectedFolder = folder
            isFolderOpen = true
        }
    }
}
