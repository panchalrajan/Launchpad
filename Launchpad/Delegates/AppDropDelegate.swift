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
        
        // Delay the animation
        DispatchQueue.main.asyncAfter(deadline: .now() + dropDelay) {
            withAnimation(.easeInOut(duration: 0.2)) {
                items.move(fromOffsets: IndexSet([fromIndex]), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
            }
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
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
                print("Default")
            }
        }
        
        self.draggedItem = nil
        return true
    }
    
    private func createFolder(with app1: AppInfo, and app2: AppInfo) {
        var targetIndex = items.firstIndex(where: { $0.id == targetItem.id }) ?? items.count
        let app1Index = items.firstIndex(where: { $0.id == app1.id }) ?? items.count
        let app2Index = items.firstIndex(where: { $0.id == app2.id }) ?? items.count
        
        if(app1Index > app2Index) {
            targetIndex+=1
        }
        else {
            targetIndex-=1
        }
        
        items.removeAll { item in item.id == app1.id || item.id == app2.id }
        
        let newFolder = Folder(name: "New folder", apps: [app1, app2])
        let insertIndex = min(targetIndex, items.count)
        items.insert(.folder(newFolder), at: insertIndex)
    }
    
    private func addAppToFolder(_ app: AppInfo, targetFolder: Folder) {
        var targetIndex = items.firstIndex(where: { $0.id == targetFolder.id }) ?? items.count
        let app1Index = items.firstIndex(where: { $0.id == app.id }) ?? items.count
        
        if(app1Index > targetIndex) {
            targetIndex+=1
        }
        
        var updatedApps = targetFolder.apps
        updatedApps.append(app)
        
        let updatedFolder = Folder(
            name: targetFolder.name,
            apps: updatedApps,
            color: targetFolder.color
        )
        
        items.removeAll { $0.id == app.id }
        
        items[targetIndex] = .folder(updatedFolder)
    }
}
