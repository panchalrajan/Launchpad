import SwiftUI

struct SearchResultsView: View {
   let apps: [AppInfo]
   let settings: LaunchpadSettings
   let onItemTap: (AppGridItem) -> Void
   
   var body: some View {
      GeometryReader { geo in
         let layout = LayoutMetrics(size: geo.size, columns: settings.columns, rows: settings.rows, iconSize: settings.iconSize)
         
         if apps.isEmpty {
            EmptySearchView()
         } else {
            ScrollView(.vertical, showsIndicators: false) {
               LazyVGrid(
                  columns: GridLayoutUtility.createGridColumns(count: settings.columns, cellWidth: layout.cellWidth, spacing: layout.hSpacing),
                  spacing: layout.hSpacing
               ) {
                  ForEach(apps) { app in
                     AppIconView(app: app, layout: layout, isDragged: false)
                        .onTapGesture {
                           onItemTap(.app(app))
                        }
                        .contextMenu {
                           Button(action: {
                              AppManager.shared.hideApp(path: app.path, appsPerPage: settings.appsPerPage)
                           }) {
                              Label(L10n.hideApp, systemImage: "eye.slash")
                           }
                        }
                  }
               }
               .padding(.horizontal, layout.hPadding)
               .padding(.vertical, layout.vPadding)
            }
         }
      }
   }
}
