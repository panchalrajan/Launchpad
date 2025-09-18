import SwiftUI
import AppKit

struct SearchResultsView: View {
    let apps: [AppInfo]
    let columns: Int
    let iconSizeMultiplier: Double
    @State private var isVisible = false
    
    var body: some View {
        GeometryReader { geo in
            let layout = LayoutMetrics(size: geo.size, columns: columns, iconSizeMultiplier: iconSizeMultiplier)
            
            if apps.isEmpty {
                EmptySearchView()
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.fixed(layout.cellWidth), spacing: layout.spacing), count: columns),
                        spacing: layout.spacing
                    ) {
                        ForEach(apps) { app in
                            AppIconView(app: app, layout: layout, isDragged: false)
                        }
                    }
                    .padding(.horizontal, layout.hPadding)
                    .padding(.vertical, layout.vPadding)
                }
                .onTapGesture {
                    NSApp.terminate(nil)
                }
            }
        }
        .scaleEffect(isVisible ? 1 : 0.85)
        .opacity(isVisible ? 1 : 0)
        .animation(.easeInOut(duration: 0.3), value: isVisible)
        .onAppear { isVisible = true }
        .onDisappear { isVisible = false }
    }
}
