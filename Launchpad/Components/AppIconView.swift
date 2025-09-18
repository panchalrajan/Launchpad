import SwiftUI
import AppKit

struct AppIconView: View {
    let app: AppInfo
    let layout: LayoutMetrics
    let isDragged: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            Image(nsImage: app.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: layout.iconSize, height: layout.iconSize)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text(app.name)
                .font(.system(size: layout.fontSize))
                .multilineTextAlignment(.center)
                .frame(width: layout.cellWidth)
        }
        .scaleEffect(isDragged ? 0.8 : 1.0)
        .opacity(isDragged ? 0.5 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isDragged)
    }
}
