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
                    spacing: layout.spacing
                ) {
                    ForEach(apps) { app in
                        AppIconView(
                            app: app,
                            layout: layout,
                            isDragged: draggedApp?.id == app.id
                        )
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
        .onTapGesture {
            NSWorkspace.shared.open(URL(fileURLWithPath: app.path))
            NSApp.terminate(nil)
        }
    }
}

struct AppDropDelegate: DropDelegate {
    let app: AppInfo
    @Binding var apps: [AppInfo]
    @Binding var draggedApp: AppInfo?
    
    func performDrop(info: DropInfo) -> Bool {
        draggedApp = nil
        // Save the new order to persistent storage
        print("Saving app order after drag and drop...")
        AppOrderManager.shared.saveAppOrder(apps)
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedApp = draggedApp,
              draggedApp.id != app.id,
              let fromIndex = apps.firstIndex(where: { $0.id == draggedApp.id }),
              let toIndex = apps.firstIndex(where: { $0.id == app.id }) else { return }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            apps.move(fromOffsets: IndexSet([fromIndex]), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}


