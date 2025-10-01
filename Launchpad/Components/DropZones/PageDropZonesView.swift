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
         .allowsHitTesting(true) // Keep hit testing for left drop zone

         Spacer()
            .allowsHitTesting(false) // Allow drops to pass through to content below

         DropZoneView(
            direction: .right,
            currentPage: currentPage,
            totalPages: totalPages,
            draggedItem: draggedItem,
            onNavigate: onNavigateRight
         )
         .allowsHitTesting(true) // Keep hit testing for right drop zone
      }
   }
}
