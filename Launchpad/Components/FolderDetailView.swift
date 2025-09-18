import SwiftUI

struct FolderDetailView: View {
    @Binding var folder: Folder
    let iconSize: Double
    let columns: Int
    let dropDelay: Double
    let onDismiss: () -> Void
    @State private var editingName = false
    @State private var draggedApp: AppInfo?
    
    init(folder: Binding<Folder>, iconSize: Double, columns: Int, dropDelay: Double, onDismiss: @escaping () -> Void) {
        self._folder = folder
        self.iconSize = iconSize
        self.columns = columns
        self.dropDelay = dropDelay
        self.onDismiss = onDismiss
    }
    
    var body: some View {
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
                        .foregroundColor(.primary)
                        .onTapGesture {
                            editingName = true
                        }
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            
            GeometryReader { geo in
                let layout = LayoutMetrics(size: geo.size, columns: columns, iconSize: iconSize)
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(
                        columns: GridLayoutUtility.createGridColumns(count: columns, cellWidth: layout.cellWidth, spacing: layout.spacing),
                        spacing: layout.spacing
                    ) {
                        ForEach(folder.apps) { app in
                            AppIconView(app: app, layout: layout, isDragged: draggedApp?.id == app.id)
                                .onTapGesture {
                                    AppLauncher.shared.launch(app.path)
                                }
                                .onDrag {
                                    draggedApp = app
                                    return NSItemProvider(object: app.id.uuidString as NSString)
                                }
                                .onDrop(of: [.text], delegate: FolderDropDelegate(
                                    dropDelay: dropDelay,
                                    targetApp: app,
                                    folder: $folder,
                                    draggedApp: $draggedApp
                                ))
                                .contextMenu {
                                    Button("Remove from Folder") {
                                        removeApp(app)
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, layout.hPadding)
                    .padding(.vertical, layout.vPadding)
                }
            }
        }
        .frame(width: 1000, height: 800)
        .background(Color(NSColor.windowBackgroundColor).opacity(0.8))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
    
    private func removeApp(_ app: AppInfo) {
        let updatedApps = folder.apps.filter { $0.id != app.id }
        let updatedFolder = Folder(name: folder.name, apps: updatedApps)
        folder = updatedFolder
    }
}
