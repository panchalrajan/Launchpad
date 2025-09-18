import SwiftUI

struct FolderDetailView: View {
    @Binding var folder: Folder
    let iconSize: Double
    let columns: Int
    let dropDelay: Double
    let onDismiss: () -> Void
    @State private var editingName = false
    @State private var draggedApp: AppInfo?
    @State private var isAnimatingIn = false
    @Environment(\.colorScheme) private var colorScheme
    
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
            color: colorScheme == .dark 
            ? Color.black.opacity(0.5) 
            : Color.black.opacity(0.2), 
            radius: 30, x: 0, y: 15
        )
        .shadow(
            color: colorScheme == .dark 
            ? Color.black.opacity(0.3) 
            : Color.black.opacity(0.08), 
            radius: 5, x: 0, y: 2
        )
        .scaleEffect(isAnimatingIn ? 1.0 : 0.9)
        .opacity(isAnimatingIn ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.interpolatingSpring(stiffness: 300, damping: 25)) {
                isAnimatingIn = true
            }
        }
    }
    
    private func removeApp(_ app: AppInfo) {
        let updatedApps = folder.apps.filter { $0.id != app.id }
        let updatedFolder = Folder(name: folder.name, apps: updatedApps)
        folder = updatedFolder
    }
}
