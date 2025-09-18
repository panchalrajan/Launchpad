import SwiftUI
import UniformTypeIdentifiers

struct AppDropDelegate: DropDelegate {
    let dropDelay: Double
    let targetItem: AppGridItem
    
    @Binding var items: [AppGridItem]
    @Binding var draggedItem: AppGridItem?
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = draggedItem,
              draggedItem.id != targetItem.id,
              let fromIndex = items.firstIndex(where: { $0.id == draggedItem.id }),
              let toIndex = items.firstIndex(where: { $0.id == targetItem.id }) else { return }
        
        // Always allow reordering animation for visual feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + dropDelay) {
            if(self.draggedItem != nil){
                withAnimation(.easeInOut(duration: 0.2)) {
                    items.move(fromOffsets: IndexSet([fromIndex]), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
                }
            }
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        print("Drop updated")
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        print("Performing drop")
        
        guard let draggedItem = draggedItem else {
            print("No dragged item found")
            self.draggedItem = nil
            return true
        }
        
        if draggedItem.id != targetItem.id {
            switch (draggedItem, targetItem) {
            case (.app(let draggedApp), .app(let targetApp)):
                print("Creating folder with apps: \(draggedApp.name) + \(targetApp.name)")
                createFolder(with: draggedApp, and: targetApp)
                print("Folder creation completed")
            case (.app(let draggedApp), .folder(let targetFolder)):
                print("Adding app \(draggedApp.name) to folder \(targetFolder.name)")
                addAppToFolder(draggedApp, targetFolder: targetFolder)
                print("App added to folder completed")
            default:
                print("Regular reordering completed")
                // No additional action needed - dropEntered already handled the reordering
            }
        }
        
        self.draggedItem = nil
        return true
    }
    
    private func createFolder(with app1: AppInfo, and app2: AppInfo) {
        // We need to use the targetItem's original position, not the current positions after reordering
        // The targetItem represents where the user actually dropped the app
        guard let originalTargetIndex = items.firstIndex(where: { $0.id == targetItem.id }),
              let draggedIndex = items.firstIndex(where: { $0.id == app1.id }),
              originalTargetIndex < items.count,
              draggedIndex < items.count else {
            print("Error: Could not find valid indices for folder creation")
            return
        }
        
        // Store the original target position before any modifications
        let folderPosition = originalTargetIndex
        
        // Create the new folder
        let newFolder = Folder(name: "New folder", apps: [app1, app2])
        
        // Remove both apps from the array in the correct order to avoid index shifting
        let indicesToRemove = [originalTargetIndex, draggedIndex].sorted(by: >)
        for index in indicesToRemove {
            if index < items.count {
                items.remove(at: index)
            }
        }
        
        // Insert folder at the original target position, adjusted for the dragged item removal
        let adjustedTargetIndex = draggedIndex < folderPosition ? folderPosition - 1 : folderPosition
        let insertIndex = min(max(0, adjustedTargetIndex), items.count)
        
        items.insert(.folder(newFolder), at: insertIndex)
    }
    
    private func addAppToFolder(_ app: AppInfo, targetFolder: Folder) {
        guard let targetIndex = items.firstIndex(where: { $0.id == targetFolder.id }),
              let appIndex = items.firstIndex(where: { $0.id == app.id }),
              targetIndex < items.count,
              appIndex < items.count else {
            print("Error: Could not find valid indices for adding app to folder")
            return
        }
        
        // Check if app is already in the folder
        if targetFolder.apps.contains(where: { $0.id == app.id }) {
            print("Warning: App \(app.name) is already in folder \(targetFolder.name)")
            return
        }
        
        // Create updated folder with the new app
        var updatedApps = targetFolder.apps
        updatedApps.append(app)
        
        let updatedFolder = Folder(
            name: targetFolder.name,
            apps: updatedApps,
            color: targetFolder.color
        )
        
        // Remove the app from the array
        items.remove(at: appIndex)
        
        // Calculate the correct folder index after app removal
        let adjustedIndex = targetIndex > appIndex ? targetIndex - 1 : targetIndex
        
        // Replace the folder at the correct position
        if adjustedIndex >= 0 && adjustedIndex < items.count {
            items[adjustedIndex] = .folder(updatedFolder)
        } else {
            print("Error: Adjusted index \(adjustedIndex) is out of bounds, items count: \(items.count)")
        }
    }
}
