import SwiftUI
import AppKit

struct FolderIconView: View {
    let folder: Folder
    let layout: LayoutMetrics
    let isDragged: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: layout.iconSize * 0.2)
                    .fill(LinearGradient( colors: [ folder.color.color.opacity(0.2), folder.color.color.opacity(0.4) ], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame( width: layout.iconSize * 0.82, height: layout.iconSize * 0.82)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 1, alignment: .top), count: 3)) {
                    ForEach(folder.previewApps) { app in
                        Image(nsImage: app.icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: layout.iconSize * 0.2, height: layout.iconSize * 0.2)
                    }
                }
                .frame(width: layout.iconSize * 0.7, height: layout.iconSize * 0.7)
            }
            .frame(width: layout.iconSize, height: layout.iconSize)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
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
