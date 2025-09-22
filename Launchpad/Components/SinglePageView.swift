import SwiftUI

struct SinglePageView: View {
  let pageItems: [AppGridItem]
  let pageIndex: Int
  let settings: LaunchpadSettings
  let isFolderOpen: Bool

  @Binding var pages: [[AppGridItem]]
  @Binding var draggedItem: AppGridItem?

  let onItemTap: (AppGridItem) -> Void

  var body: some View {
    GeometryReader { pageGeo in
      let layout = LayoutMetrics(size: pageGeo.size, columns: settings.columns, iconSize: settings.iconSize)
      let logicalPageNumber = pageItems.first?.page ?? pageIndex

      ScrollView(.horizontal, showsIndicators: false) {
        LazyVGrid(
          columns: GridLayoutUtility.createGridColumns(
            count: settings.columns, cellWidth: layout.cellWidth, spacing: layout.spacing),
          spacing: layout.spacing
        ) {
          ForEach(pageItems) { item in
            GridItemView(
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
            .onDrop(
              of: [.text],
              delegate: ItemDropDelegate(
                pages: $pages,
                draggedItem: $draggedItem,
                dropDelay: settings.dropDelay,
                targetItem: item,
                targetPage: logicalPageNumber,
                appsPerPage: settings.appsPerPage
              ))
          }
        }
        .padding(.horizontal, layout.hPadding)
        .padding(.vertical, layout.vPadding)
      }
    }
  }
}
