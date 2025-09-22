import SwiftUI

struct FolderRemoveDropDelegate: DropDelegate {
  @Binding var folder: Folder
  @Binding var draggedApp: AppInfo?
  let onRemoveApp: ((AppInfo) -> Void)

  func performDrop(info: DropInfo) -> Bool {
    guard let draggedApp = draggedApp else { return true }
    if let index = folder.apps.firstIndex(where: { $0.id == draggedApp.id }) {
      let removedApp = folder.apps.remove(at: index)
      self.draggedApp = nil
      onRemoveApp(removedApp)
    }

    return true
  }
}
