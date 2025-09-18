import SwiftUI
import UniformTypeIdentifiers

struct AppGridItemDropDelegate: DropDelegate {
    let targetItem: AppGridItem
    @Binding var items: [AppGridItem]
    @Binding var draggedItem: AppGridItem?
    
    func dropEntered(info: DropInfo) {
        // Visual feedback when hovering over a drop target
    }
    
    func dropExited(info: DropInfo) {
        // Remove visual feedback
    }
    
    func performDrop(info: DropInfo) -> Bool {
        guard let draggedItem = draggedItem else { 
            return false 
        }
        
        // Don't allow dropping on self
        if draggedItem.id == targetItem.id {
            return false
        }
        
        // Handle different drop scenarios
        switch (draggedItem, targetItem) {
        case (.app(let draggedApp), .app(let targetApp)):
            // App dropped on app - create folder
            createFolder(with: draggedApp, and: targetApp)
            return true
            
        case (.app(let draggedApp), .folder(let targetFolder)):
            // App dropped on folder - add to folder
            addAppToFolder(draggedApp, targetFolder: targetFolder)
            return true
            
        case (.folder, .app):
            // Folder dropped on app - just reorder
            reorderItems(draggedItem: draggedItem, targetItem: targetItem)
            return true
            
        case (.folder, .folder):
            // Folder dropped on folder - just reorder (could implement merge later)
            reorderItems(draggedItem: draggedItem, targetItem: targetItem)
            return true
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    private func createFolder(with app1: AppInfo, and app2: AppInfo) {
        // Find the position where the target app was before removing
        let targetIndex = items.firstIndex(where: { $0.id == targetItem.id }) ?? items.count
        
        // Remove both apps from the grid
        items.removeAll { item in
            item.id == app1.id || item.id == app2.id
        }
        
        // Create a new folder with both apps
        let folderName = suggestFolderName(for: [app1, app2])
        let newFolder = Folder(name: folderName, apps: [app1, app2])
        
        // Insert the folder at the correct position
        let insertIndex = min(targetIndex, items.count)
        items.insert(.folder(newFolder), at: insertIndex)
        
        draggedItem = nil
    }
    
    private func addAppToFolder(_ app: AppInfo, targetFolder: Folder) {
        // Find the folder in the items array and update it
        guard let folderIndex = items.firstIndex(where: { $0.id == targetFolder.id }) else {
            return
        }
        
        // Get the current folder
        guard case .folder(let currentFolder) = items[folderIndex] else {
            return
        }
        
        // Create a new folder with the app added (if not already present)
        var updatedApps = currentFolder.apps
        if !updatedApps.contains(where: { $0.id == app.id }) {
            updatedApps.append(app)
        } else {
            return
        }
        
        // Create new folder instance with updated apps
        let updatedFolder = Folder(
            name: currentFolder.name,
            apps: updatedApps,
            color: currentFolder.color
        )
        
        // Remove the app from the grid first
        items.removeAll { $0.id == app.id }
        
        // Find the folder again (index might have changed after removal)
        guard let newFolderIndex = items.firstIndex(where: { $0.id == targetFolder.id }) else {
            return
        }
        
        // Update the folder in the grid with new instance
        items[newFolderIndex] = .folder(updatedFolder)
        
        draggedItem = nil
    }
    
    private func reorderItems(draggedItem: AppGridItem, targetItem: AppGridItem) {
        guard let draggedIndex = items.firstIndex(where: { $0.id == draggedItem.id }),
              let targetIndex = items.firstIndex(where: { $0.id == targetItem.id }) else {
            return
        }
        
        let movedItem = items.remove(at: draggedIndex)
        
        let newIndex = draggedIndex < targetIndex ? targetIndex - 1 : targetIndex
        items.insert(movedItem, at: newIndex)
        
        self.draggedItem = nil
    }
    
    private func suggestFolderName(for apps: [AppInfo]) -> String {
        // Simple categorization based on app names
        let appNames = apps.map { $0.name.lowercased() }
        
        let categories = [
            "Utilities": ["terminal", "console", "activity monitor", "disk utility", "finder"],
            "Development": ["xcode", "terminal", "git", "github", "vs code", "visual studio"],
            "Graphics": ["photoshop", "illustrator", "sketch", "figma", "pixelmator"],
            "Communication": ["slack", "discord", "teams", "zoom", "skype", "mail"],
            "Entertainment": ["spotify", "music", "netflix", "youtube", "vlc"],
            "Productivity": ["notes", "calendar", "reminders", "pages", "numbers", "keynote"]
        ]
        
        for (category, keywords) in categories {
            if appNames.contains(where: { appName in
                keywords.contains { appName.contains($0) }
            }) {
                return category
            }
        }
        
        return "Folder"
    }
}
