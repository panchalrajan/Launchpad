import SwiftUI
import Foundation

struct FolderDetailView: View {
    @Binding var folder: Folder
    let iconSize: Double
    let columns: Int
    let dropDelay: Double
    let onSave: () -> Void
    
    @State private var editingName = false
    @State private var draggedApp: AppInfo?
    @State private var isAnimatingIn = false
    @Environment(\.colorScheme) private var colorScheme
    
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
                            onSave()
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
        // Prevent tap gesture propagation to parent by disabling hit testing on background
        .contentShape(Rectangle())
        .onTapGesture {
            // Do nothing, just consume the tap
        }
    }
    
    private func removeApp(_ app: AppInfo) {
        folder = Folder(
            name: folder.name,
            page: folder.page,
            apps: folder.apps.filter { $0.id != app.id }
        )
        onSave()
    }
}
