/*
import SwiftUI

struct GridDropDelegate: DropDelegate {
    let dropDelay: Double
    let targetItem: AppGridItem
    let targetPage: Int
    let appsPerPage: Int
    
    @Binding var pages: [[AppGridItem]]
    @Binding var draggedItem: AppGridItem?
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = draggedItem,
              draggedItem.id != targetItem.id,
              let fromIndex = items.firstIndex(where: { $0.id == draggedItem.id }),
              let toIndex = items.firstIndex(where: { $0.id == targetItem.id }) else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + dropDelay) {
            if(self.draggedItem != nil){
                DropAnimationHelper.performDelayedMove(delay: 0) {
                    items.move(fromOffsets: IndexSet([fromIndex]), toOffset: DropAnimationHelper.calculateMoveOffset(fromIndex: fromIndex, toIndex: toIndex))
                }
            }
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        
        guard let draggedItem = draggedItem else {
            self.draggedItem = nil
            return true
        }
        
        if draggedItem.id != targetItem.id {
            switch (draggedItem, targetItem) {
            case (.app(let draggedApp), .app(let targetApp)):
                createFolder(with: draggedApp, and: targetApp)
            case (.app(let draggedApp), .folder(let targetFolder)):
                addAppToFolder(draggedApp, targetFolder: targetFolder)
            default:
                break
            }
        }
        
        self.draggedItem = nil
        return true
    }
    
    private func createFolder(with app1: AppInfo, and app2: AppInfo) {
        guard let originalTargetIndex = items.firstIndex(where: { $0.id == targetItem.id }),
              let draggedIndex = items.firstIndex(where: { $0.id == app1.id }) else { return }
        
        let newFolder = Folder(name: "New folder", apps: [app1, app2])
        
        // Remove apps in descending order to avoid index shifting
        let indicesToRemove = [originalTargetIndex, draggedIndex].sorted(by: >)
        for index in indicesToRemove {
            if index < items.count {
                items.remove(at: index)
            }
        }
        
        let adjustedTargetIndex = draggedIndex < originalTargetIndex ? originalTargetIndex - 1 : originalTargetIndex
        let insertIndex = min(max(0, adjustedTargetIndex), items.count)
        
        items.insert(.folder(newFolder), at: insertIndex)
    }
    
    private func addAppToFolder(_ app: AppInfo, targetFolder: Folder) {
        guard let targetIndex = items.firstIndex(where: { $0.id == targetFolder.id }),
              let appIndex = items.firstIndex(where: { $0.id == app.id }) else {
            return
        }
        
        if targetFolder.apps.contains(where: { $0.id == app.id }) {
            return
        }
        
        let updatedFolder = Folder(
            name: targetFolder.name,
            apps: targetFolder.apps + [app]
        )
        
        items.remove(at: appIndex)
        
        let adjustedIndex = targetIndex > appIndex ? targetIndex - 1 : targetIndex
        
        if adjustedIndex >= 0 && adjustedIndex < items.count {
            items[adjustedIndex] = .folder(updatedFolder)
        }
    }
}
*/
