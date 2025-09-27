import SwiftUI

struct SearchResultsView: View {
    let apps: [AppInfo]
    let settings: LaunchpadSettings
    let layout: LayoutMetrics
    let onItemTap: (AppGridItem) -> Void
    
    var body: some View {
        if apps.isEmpty {
            EmptySearchView()
        } else {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(
                    columns: GridLayoutUtility.createGridColumns(count: settings.columns, cellWidth: layout.cellWidth, spacing: layout.hSpacing),
                    spacing: layout.vSpacing) {
                        ForEach(apps) { app in
                            AppIconView(app: app, layout: layout, isDragged: false)
                                .onTapGesture {
                                    onItemTap(.app(app))
                                }
                        }
                    }
                    .padding(.horizontal, layout.hPadding)
                    .padding(.vertical, layout.vPadding)
            }
        }
    }
}
