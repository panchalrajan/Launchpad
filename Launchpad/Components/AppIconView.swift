import AppKit
import SwiftUI

struct AppIconView: View {
   let app: AppInfo
   let layout: LayoutMetrics
   let isDragged: Bool
   
   var body: some View {
      VStack(spacing: 8) {
         Image(nsImage: app.icon)
            .interpolation(.high)
            .resizable()
            .frame(width: layout.iconSize, height: layout.iconSize)
         
         Text(app.name)
            .font(.system(size: layout.fontSize))
            .multilineTextAlignment(.center)
            .frame(width: layout.cellWidth)
      }
      .scaleEffect(isDragged ? 0.8 : 1.0)
      .opacity(isDragged ? 0.5 : 1.0)
      .animation(.easeInOut(duration: 0.2), value: isDragged)
      .onTapGesture {
         AppLauncher.launch(path: app.path)
      }
   }
}
