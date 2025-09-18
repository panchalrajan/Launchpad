import SwiftUI
import AppKit

struct AppGridView: View {
    @Binding var items: [AppGridItem]
    let columns: Int
    let iconSizeMultiplier: Double
    let dropDelay: Double
    @State private var isVisible = false
    @State private var draggedItem: AppGridItem?
    @State private var selectedFolder: Folder?
    @State private var showingFolderDetail = false
    
    var body: some View {
        GeometryReader { geo in
            let layout = LayoutMetrics(size: geo.size, columns: columns, iconSizeMultiplier: iconSizeMultiplier)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(layout.cellWidth), spacing: layout.spacing), count: columns),
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
                            .onDrop(of: [.text], delegate: AppDropDelegate(
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
        .scaleEffect(isVisible ? 1 : 0.85)
        .opacity(isVisible ? 1 : 0)
        .animation(.easeInOut(duration: 0.3), value: isVisible)
        .onAppear { isVisible = true }
        .onDisappear { isVisible = false }
        .sheet(isPresented: $showingFolderDetail) {
            if let folder = selectedFolder,
               let index = items.firstIndex(where: { $0.id == folder.id }),
               case .folder(let currentFolder) = items[index] {
                FolderDetailView(
                    folder: Binding(
                        get: { currentFolder },
                        set: { updatedFolder in
                            items[index] = .folder(updatedFolder)
                        }
                    ),
                    iconSizeMultiplier: iconSizeMultiplier
                )
            }
        }
    }
    
    private func handleItemTap(_ item: AppGridItem) {
        switch item {
        case .app(let app):
            // Launch the app
            NSWorkspace.shared.open(URL(fileURLWithPath: app.path))
            NSApp.terminate(nil)
        case .folder(let folder):
            // Open folder detail view
            selectedFolder = folder
            showingFolderDetail = true
        }
    }
}
