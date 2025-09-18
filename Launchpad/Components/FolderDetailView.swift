import SwiftUI

struct FolderDetailView: View {
    @Binding var folder: Folder
    @Environment(\.dismiss) private var dismiss
    let iconSizeMultiplier: Double
    @State private var editingName = false
    @State private var tempName: String = ""
    
    init(folder: Binding<Folder>, iconSizeMultiplier: Double) {
        self._folder = folder
        self.iconSizeMultiplier = iconSizeMultiplier
        self._tempName = State(initialValue: folder.wrappedValue.name)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with folder name and close button
            HStack {
                if editingName {
                    TextField("Folder Name", text: $tempName)
                        .textFieldStyle(.roundedBorder)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .onSubmit {
                            folder.name = tempName
                            editingName = false
                        }
                        .onAppear {
                            tempName = folder.name
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
                
                Button("✕") {
                    dismiss()
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                .font(.title3)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Apps grid
            if folder.apps.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "folder")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("Empty Folder")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text("Drag apps here to add them to this folder")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                GeometryReader { geo in
                    let columns = max(4, min(8, Int(geo.size.width / 100)))
                    let layout = LayoutMetrics(size: geo.size, columns: columns, iconSizeMultiplier: iconSizeMultiplier)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.fixed(layout.cellWidth), spacing: layout.spacing), count: columns),
                            spacing: layout.spacing
                        ) {
                            ForEach(folder.apps) { app in
                                AppIconView(app: app, layout: layout, isDragged: false)
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
            
            // Color picker
            HStack {
                Text("Folder Color:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    ForEach(FolderColor.allCases, id: \.self) { color in
                        Circle()
                            .fill(color.color)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: folder.color == color ? 2 : 0)
                            )
                            .onTapGesture {
                                folder.color = color
                            }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(width: 600, height: 500)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
    
    private func removeApp(_ app: AppInfo) {
        folder.apps.removeAll { $0.id == app.id }
    }
}
