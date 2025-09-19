import SwiftUI

struct PageDropZonesView: View {
    let currentPage: Int
    let totalPages: Int
    let draggedItem: AppGridItem?
    
    @State private var isLeftDropZoneHovered = false
    @State private var isRightDropZoneHovered = false
    
    let onNavigateLeft: () -> Void
    let onNavigateRight: () -> Void
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(
                    isLeftDropZoneHovered && draggedItem != nil && currentPage > 0
                    ? Color.accentColor.opacity(0.3)
                    : Color.clear
                )
                .frame(width: 60)
                .overlay(alignment: .leading) {
                    if isLeftDropZoneHovered && draggedItem != nil && currentPage > 0 {
                        VStack {
                            Spacer()
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.accentColor)
                                .opacity(0.8)
                            Spacer()
                        }
                        .padding(.leading, 20)
                    }
                }
                .onDrop(of: [.text], isTargeted: $isLeftDropZoneHovered) { _ in
                    if currentPage > 0 {
                        onNavigateLeft()
                        return true
                    }
                    return false
                }
            
            Spacer()
            
            Rectangle()
                .fill(
                    isRightDropZoneHovered && draggedItem != nil && currentPage < totalPages - 1
                    ? Color.accentColor.opacity(0.3)
                    : Color.clear
                )
                .frame(width: 60)
                .overlay(alignment: .trailing) {
                    if isRightDropZoneHovered && draggedItem != nil && currentPage < totalPages - 1 {
                        VStack {
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.accentColor)
                                .opacity(0.8)
                            Spacer()
                        }
                        .padding(.trailing, 20)
                    }
                }
                .onDrop(of: [.text], isTargeted: $isRightDropZoneHovered) { _ in
                    if currentPage < totalPages - 1 {
                        onNavigateRight()
                        return true
                    }
                    return false
                }
        }
        .allowsHitTesting(draggedItem != nil)
    }
}