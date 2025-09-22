import Foundation
import SwiftUI

struct FolderDetailView: View {
  @Binding var folder: Folder
  let settings: LaunchpadSettings
  let onSave: () -> Void
  let onRemoveApp: ((AppInfo) -> Void)

  @State private var editingName = false
  @State private var draggedApp: AppInfo?
  @State private var isAnimatingIn = false
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    ZStack {
      Color.clear
        .contentShape(Rectangle())
        .onDrop(
          of: [.text],
          delegate: FolderRemoveDropDelegate(
            folder: $folder,
            draggedApp: $draggedApp,
            onRemoveApp: onRemoveApp,
          )
        )
        .onTapGesture {
          onSave()
        }
      VStack(spacing: 24) {
        HStack {
          Spacer()
          if editingName {
            TextField("Folder Name", text: $folder.name)
              .textFieldStyle(.roundedBorder)
              .font(.title2)
              .fontWeight(.semibold)
              .multilineTextAlignment(.center)
              .onSubmit {
                editingName = false
              }
          } else {
            Text(folder.name)
              .font(.title2)
              .fontWeight(.semibold)
              .foregroundColor(colorScheme == .dark ? .white : .primary)
              .onTapGesture {
                editingName = true
              }
          }
          Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)

        GeometryReader { geo in
            let layout = LayoutMetrics(size: geo.size, columns: settings.folderColumns, iconSize: settings.iconSize)

          ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(
              columns: GridLayoutUtility.createGridColumns(count: settings.folderColumns, cellWidth: layout.cellWidth, spacing: layout.spacing),
              spacing: layout.spacing
            ) {
              ForEach(folder.apps) { app in
                AppIconView(app: app, layout: layout, isDragged: draggedApp?.id == app.id)
                  .onDrag {
                    draggedApp = app
                    return NSItemProvider(object: app.id.uuidString as NSString)
                  }
                  .onDrop(
                    of: [.text],
                    delegate: FolderDropDelegate(
                      folder: $folder,
                      draggedApp: $draggedApp,
                      dropDelay: settings.dropDelay,
                      targetApp: app
                    ))
              }
            }
            .padding(.horizontal, layout.hPadding)
            .padding(.vertical, layout.vPadding)
          }
        }
      }
      .frame(width: 1000, height: 700)
      .background(
        ZStack {
          VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
            .cornerRadius(16)
          RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial)
            .opacity(colorScheme == .dark ? 0.4 : 0.3)
        }
      )
      .clipShape(RoundedRectangle(cornerRadius: 16))
      .shadow(
        color: colorScheme == .dark ? .black.opacity(0.5) : .black.opacity(0.2),
        radius: 30, x: 0, y: 15
      )
      .shadow(
        color: colorScheme == .dark ? .black.opacity(0.3) : .black.opacity(0.08),
        radius: 5, x: 0, y: 2
      )
      .scaleEffect(isAnimatingIn ? 1.0 : 0.9)
      .opacity(isAnimatingIn ? 1.0 : 0.0)
      .onAppear {
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 25)) {
          isAnimatingIn = true
        }
      }
      .contentShape(Rectangle())
      .onTapGesture {
      }
    }
  }
}
