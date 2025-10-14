import SwiftUI

struct GridItemView: View {
   let item: AppGridItem
   let layout: LayoutMetrics
   let isDragged: Bool
   let transparency: Double
   
   var body: some View {
      Group {
         switch item {
         case .app(let app):
            AppIconView(app: app, layout: layout, isDragged: isDragged)
         case .folder(let folder):
            FolderIconView(folder: folder, layout: layout, isDragged: isDragged, transparency: transparency)
         }
      }
   }
}
