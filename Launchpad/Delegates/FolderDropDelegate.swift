import SwiftUI

struct FolderDropDelegate: DropDelegate {
    let dropDelay: Double
    let targetApp: AppInfo
    
    @Binding var folder: Folder
    @Binding var draggedApp: AppInfo?
    
    func dropEntered(info: DropInfo) {
        guard let draggedApp = draggedApp,
              draggedApp.id != targetApp.id,
              let fromIndex = folder.apps.firstIndex(where: { $0.id == draggedApp.id }),
              let toIndex = folder.apps.firstIndex(where: { $0.id == targetApp.id }) else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + dropDelay) {
            if self.draggedApp != nil {
                DropAnimationHelper.performDelayedMove(delay: 0) {
                    var newApps = self.folder.apps
                    newApps.move(fromOffsets: IndexSet([fromIndex]), toOffset: DropAnimationHelper.calculateMoveOffset(fromIndex: fromIndex, toIndex: toIndex))
                    
                                        let updatedFolder = Folder(name: self.folder.name, page: self.folder.page, apps: newApps)
                    self.folder = updatedFolder
                }
            }
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        draggedApp = nil
        return true
    }
}
