import SwiftUI
import AppKit

struct FolderView: View {
    let folder: Folder
    let layout: LayoutMetrics
    let isDragged: Bool
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Folder background
                RoundedRectangle(cornerRadius: layout.iconSize * 0.2)
                    .fill(
                        LinearGradient(
                            colors: [
                                folder.color.color.opacity(0.8),
                                folder.color.color.opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: layout.iconSize, height: layout.iconSize)
                    .overlay(
                        RoundedRectangle(cornerRadius: layout.iconSize * 0.2)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                
                // Grid of app icons inside folder
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 2),
                    spacing: 2
                ) {
                    ForEach(folder.previewApps) { app in
                        Image(nsImage: app.icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: layout.iconSize * 0.35, height: layout.iconSize * 0.35)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    
                    // Fill empty slots with placeholder
                    ForEach(folder.previewApps.count..<4, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.2))
                            .frame(width: layout.iconSize * 0.35, height: layout.iconSize * 0.35)
                    }
                }
                .frame(width: layout.iconSize * 0.8, height: layout.iconSize * 0.8)
            }
            .scaleEffect(isDragged ? 0.8 : (isHovered ? 1.05 : 1.0))
            .opacity(isDragged ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .animation(.easeInOut(duration: 0.2), value: isDragged)
            .onHover { hovering in
                isHovered = hovering
            }
            
            // Folder name
            Text(folder.name)
                .font(.system(size: layout.fontSize))
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: layout.cellWidth)
                .opacity(isDragged ? 0.7 : 1.0)
        }
        .frame(width: layout.cellWidth, height: layout.cellWidth * 1.2)
    }
}
