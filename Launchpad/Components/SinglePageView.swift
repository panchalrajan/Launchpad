import SwiftUI

struct SinglePageView: View {
  @Binding var pages: [[AppGridItem]]
  @Binding var draggedItem: AppGridItem?
  let pageIndex: Int
  let settings: LaunchpadSettings
  let isFolderOpen: Bool
  let onItemTap: (AppGridItem) -> Void

  var body: some View {
    GeometryReader { pageGeo in
      let layout = LayoutMetrics(size: pageGeo.size, columns: settings.columns, iconSize: settings.iconSize)

      ScrollView(.horizontal, showsIndicators: false) {
        LazyVGrid(
          columns: GridLayoutUtility.createGridColumns(
            count: settings.columns, cellWidth: layout.cellWidth, spacing: layout.spacing),
          spacing: layout.spacing
        ) {
          ForEach(pages[pageIndex]) { item in
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
                targetPage: pageIndex,
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
