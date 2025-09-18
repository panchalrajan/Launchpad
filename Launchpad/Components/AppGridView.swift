import SwiftUI
import AppKit

struct AppGridView: View {
    @Binding var apps: [AppInfo]
    let columns: Int
    @State private var isVisible = false
    @State private var draggedApp: AppInfo?
    
    var body: some View {
        GeometryReader { geo in
            let layout = LayoutMetrics(size: geo.size, columns: columns)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(layout.cellWidth), spacing: layout.spacing), count: columns),
                    spacing: layout.spacing) {
                        ForEach(apps) { app in
                            AppIconView(app: app, layout: layout, isDragged: draggedApp?.id == app.id)
                                .onDrag {
                                    draggedApp = app
                                    return NSItemProvider(object: app.id.uuidString as NSString)
                                }
                                .onDrop(of: [.text], delegate: AppDropDelegate(
                                    app: app,
                                    apps: $apps,
                                    draggedApp: $draggedApp
                                ))
                        }
                    }
                    .padding(.horizontal, layout.hPadding)
                    .padding(.vertical, layout.vPadding)
            }
        }
        .scaleEffect(isVisible ? 1 : 0.85)
        .opacity(isVisible ? 1 : 0)
        .animation(.easeInOut(duration: 0.3), value: isVisible)
        .onAppear { isVisible = true }
        .onDisappear { isVisible = false }
    }
}
