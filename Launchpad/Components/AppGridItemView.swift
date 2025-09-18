import SwiftUI
import AppKit

struct AppGridItemView: View {
    let item: AppGridItem
    let layout: LayoutMetrics
    let isDragged: Bool
    
    var body: some View {
        switch item {
        case .app(let app):
            AppIconView(app: app, layout: layout, isDragged: isDragged)
        case .folder(let folder):
            FolderView(folder: folder, layout: layout, isDragged: isDragged)
        }
    }
}
