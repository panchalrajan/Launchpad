import SwiftUI

struct LocationsSettings: View {
   @Binding var settings: LaunchpadSettings
   @State private var newLocation: String = ""
   @State private var showingAlert = false
   @State private var alertMessage = ""
   
   var body: some View {
      VStack(alignment: .leading, spacing: 20) {
         Text(L10n.locationsDescription)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .fixedSize(horizontal: false, vertical: true)
         
         VStack(alignment: .leading, spacing: 8) {
            Text(L10n.addLocation)
               .font(.headline)
               .foregroundColor(.primary)
            
            HStack(spacing: 8) {
               TextField(L10n.locationPlaceholder, text: $newLocation)
                  .textFieldStyle(.roundedBorder)
                  .font(.system(.body, design: .monospaced))
               
               Button(action: selectFolder) {
                  Image(systemName: "folder")
               }
               .buttonStyle(.bordered)
               .help(L10n.browseFolder)
               
               Button(action: addLocation) {
                  Image(systemName: "plus.circle.fill")
               }
               .buttonStyle(.borderedProminent)
               .disabled(newLocation.trimmingCharacters(in: .whitespaces).isEmpty)
               .help(L10n.addLocationHelp)
            }
         }
         
         VStack(alignment: .leading, spacing: 12) {
            Text(L10n.customLocations)
               .font(.headline)
               .foregroundColor(.primary)
            
            if settings.customAppLocations.isEmpty {
               Text(L10n.noCustomLocations)
                  .font(.subheadline)
                  .foregroundColor(.secondary)
                  .italic()
                  .padding(.vertical, 8)
            } else {
               ScrollView {
                  VStack(spacing: 8) {
                     ForEach(Array(settings.customAppLocations.enumerated()), id: \.offset) { index, location in
                        HStack {
                           Image(systemName: "folder.fill")
                              .foregroundColor(.blue)
                           Text(location)
                              .font(.system(.body, design: .monospaced))
                              .lineLimit(1)
                              .truncationMode(.middle)
                           Spacer()
                           Button(action: {
                              removeLocation(at: index)
                           }) {
                              Image(systemName: "trash")
                                 .foregroundColor(.red)
                           }
                           .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                           RoundedRectangle(cornerRadius: 6)
                              .fill(Color.primary.opacity(0.05))
                        )
                     }
                  }
               }
               .frame(maxHeight: 150)
            }
         }
      }
      .padding(.horizontal, 8)
      .alert(L10n.invalidLocation, isPresented: $showingAlert) {
         Button(L10n.ok, role: .cancel) { }
      } message: {
         Text(alertMessage)
      }
   }
   
   private func addLocation() {
      let trimmedLocation = newLocation.trimmingCharacters(in: .whitespaces)
      
      guard !trimmedLocation.isEmpty else { return }
      
      // Check if the path exists
      var isDirectory: ObjCBool = false
      let exists = FileManager.default.fileExists(atPath: trimmedLocation, isDirectory: &isDirectory)
      
      if !exists {
         alertMessage = L10n.locationDoesNotExist
         showingAlert = true
         return
      }
      
      if !isDirectory.boolValue {
         alertMessage = L10n.locationNotDirectory
         showingAlert = true
         return
      }
      
      // Check if location already exists
      if settings.customAppLocations.contains(trimmedLocation) {
         alertMessage = L10n.locationAlreadyAdded
         showingAlert = true
         return
      }
      
      settings.customAppLocations.append(trimmedLocation)
      newLocation = ""
   }
   
   private func removeLocation(at index: Int) {
      settings.customAppLocations.remove(at: index)
   }
   
   private func selectFolder() {
      let panel = NSOpenPanel()
      panel.canChooseFiles = false
      panel.canChooseDirectories = true
      panel.allowsMultipleSelection = false
      panel.message = L10n.selectFolderMessage
      
      if panel.runModal() == .OK, let url = panel.url {
         newLocation = url.path
      }
   }
}
