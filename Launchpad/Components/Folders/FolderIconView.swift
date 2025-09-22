import AppKit
import SwiftUI

struct FolderIconView: View {
  let folder: Folder
  let layout: LayoutMetrics
  let isDragged: Bool
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    VStack(spacing: 8) {
      ZStack {
        RoundedRectangle(cornerRadius: layout.iconSize * 0.2)
          .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white.opacity(0.3))
          .background(
            RoundedRectangle(cornerRadius: layout.iconSize * 0.2)
              .fill(.ultraThinMaterial)
          )
          .frame(width: layout.iconSize * 0.82, height: layout.iconSize * 0.82)

        LazyVGrid(columns: GridLayoutUtility.createFlexibleGridColumns(count: 3, spacing: 1)) {
          ForEach(folder.previewApps) { app in
            Image(nsImage: app.icon)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: layout.iconSize * 0.2, height: layout.iconSize * 0.2)
          }

          ForEach(folder.previewApps.count..<9, id: \.self) { _ in
            RoundedRectangle(cornerRadius: 4)
              .fill(Color.clear)
              .frame(width: layout.iconSize * 0.2, height: layout.iconSize * 0.2)
          }
        }
        .frame(width: layout.iconSize * 0.6, height: layout.iconSize * 0.6)
      }
      .frame(width: layout.iconSize, height: layout.iconSize)
      .clipShape(RoundedRectangle(cornerRadius: 16))
      .shadow(
        color: colorScheme == .dark ? Color.black.opacity(0.6) : Color.black.opacity(0.3),
        radius: 12, x: 0, y: 6
      )
      .shadow(
        color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.1),
        radius: 4, x: 0, y: 2
      )

      Text(folder.name)
        .font(.system(size: layout.fontSize))
        .multilineTextAlignment(.center)
        .frame(width: layout.cellWidth)
    }
    .scaleEffect(isDragged ? 0.8 : 1.0)
    .opacity(isDragged ? 0.5 : 1.0)
    .animation(.easeInOut(duration: 0.2), value: isDragged)
  }
}
