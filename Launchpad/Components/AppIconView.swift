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
      .scaleEffect(isDragged ? LaunchPadConstants.draggedItemScale : 1.0)
      .opacity(isDragged ? LaunchPadConstants.draggedItemOpacity : 1.0)
      .animation(LaunchPadConstants.quickFadeAnimation, value: isDragged)
   }
}
