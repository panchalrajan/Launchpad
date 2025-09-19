import SwiftUI

struct SinglePageView: View {
    let pageItems: [AppGridItem]
    let pageIndex: Int
    let columns: Int
    let rows: Int
    let iconSize: Double
    let dropDelay: Double
    let isFolderOpen: Bool
    
    @Binding var pages: [[AppGridItem]]
    @Binding var draggedItem: AppGridItem?
    
    let onItemTap: (AppGridItem) -> Void
    
    var body: some View {
        GeometryReader { pageGeo in
            let layout = LayoutMetrics(size: pageGeo.size, columns: columns, iconSize: iconSize)
            let logicalPageNumber = pageItems.first?.page ?? pageIndex
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyVGrid(
                    columns: GridLayoutUtility.createGridColumns(count: columns, cellWidth: layout.cellWidth, spacing: layout.spacing),
                    spacing: layout.spacing) {
                        ForEach(pageItems) { item in
                            AppGridItemView(
                                item: item,
                                layout: layout,
                                isDragged: draggedItem?.id == item.id
                            )
                            .opacity(isFolderOpen ? 0.2 : 1)
                            .onTapGesture {
                                onItemTap(item)
                            }
                            .onDrag {
                                draggedItem = item
                                return NSItemProvider(object: item.id.uuidString as NSString)
                            }
                            .onDrop(of: [.text], delegate: ItemDropDelegate(
                                dropDelay: dropDelay,
                                targetItem: item,
                                targetPage: logicalPageNumber,
                                appsPerPage: columns * rows,
                                pages: $pages,
                                draggedItem: $draggedItem
                            ))
                        }
                    }
                    .padding(.horizontal, layout.hPadding)
                    .padding(.vertical, layout.vPadding)
            }
        }
    }
}