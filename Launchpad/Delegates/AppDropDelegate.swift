import SwiftUI
import AppKit

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
