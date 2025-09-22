import SwiftUI

struct PageDropZonesView: View {
  let currentPage: Int
  let totalPages: Int
  let draggedItem: AppGridItem?
  let onNavigateLeft: () -> Void
  let onNavigateRight: () -> Void

  var body: some View {
    HStack {
      DropZoneView(
        direction: .left,
        currentPage: currentPage,
        totalPages: totalPages,
        draggedItem: draggedItem,
        onNavigate: onNavigateLeft
      )

      Spacer()

      DropZoneView(
        direction: .right,
        currentPage: currentPage,
        totalPages: totalPages,
        draggedItem: draggedItem,
        onNavigate: onNavigateRight
      )
    }
  }
}
