import SwiftUI

struct SearchResultsView: View {
    let apps: [AppInfo]
    let settings: LaunchpadSettings
    
    var body: some View {
        GeometryReader { geo in
            let layout = LayoutMetrics(size: geo.size, columns: settings.columns, iconSize: settings.iconSize)
            
            if apps.isEmpty {
                EmptySearchView()
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(
                        columns: GridLayoutUtility.createGridColumns(count: settings.columns, cellWidth: layout.cellWidth, spacing: layout.spacing),
                        spacing: layout.spacing
                    ) {
                        ForEach(apps) { app in
                            AppIconView(app: app, layout: layout, isDragged: false)
                        }
                    }
                    .padding(.horizontal, layout.hPadding)
                    .padding(.vertical, layout.vPadding)
                }
            }
        }
    }
}
