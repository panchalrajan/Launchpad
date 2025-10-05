import SwiftUI

struct FolderDropDelegate: DropDelegate {
    @Binding var folder: Folder
    @Binding var draggedApp: AppInfo?
    let dropDelay: Double
    let targetApp: AppInfo
    
    func performDrop(info: DropInfo) -> Bool {
        guard let draggedApp = draggedApp else { return false }
        
        self.draggedApp = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedApp = draggedApp,
              draggedApp.id != targetApp.id,
              let fromIndex = folder.apps.firstIndex(where: { $0.id == draggedApp.id }),
              let toIndex = folder.apps.firstIndex(where: { $0.id == targetApp.id })
        else { return }
        
        DropAnimationHelper.performDelayedMove(delay: dropDelay) {
            if self.draggedApp != nil {
                folder.apps.move(fromOffsets: IndexSet([fromIndex]), toOffset: DropAnimationHelper.calculateMoveOffset(fromIndex: fromIndex, toIndex: toIndex))
            }
        }
    }
    
    
}
