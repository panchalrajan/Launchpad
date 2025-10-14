import SwiftUI

struct ActionsSettings: View {
   private let settingsManager = SettingsManager.shared
   private let appManager = AppManager.shared
   
   @State private var showingClearConfirmation = false
   @State private var showingImportAlert = false
   @State private var importAlertTitle = ""
   @State private var importAlertMessage = ""
   
   var body: some View {
      VStack(alignment: .center, spacing: 20) {
         VStack(alignment: .leading, spacing: 12) {
            Text(L10n.layoutManagement)
               .font(.headline)
               .foregroundColor(.primary)
            
            Button(action: exportLayout) {
               HStack {
                  Image(systemName: "square.and.arrow.up")
                  Text(L10n.exportLayout)
                  Spacer()
               }
               .padding(.horizontal, 16)
               .padding(.vertical, 10)
               .background(Color.blue.opacity(0.1))
               .foregroundColor(.blue)
               .cornerRadius(8)
            }
            .buttonStyle(.plain)
            
            Button(action: importLayout) {
               HStack {
                  Image(systemName: "square.and.arrow.down")
                  Text(L10n.importLayout)
                  Spacer()
               }
               .padding(.horizontal, 16)
               .padding(.vertical, 10)
               .background(Color.green.opacity(0.1))
               .foregroundColor(.green)
               .cornerRadius(8)
            }
            .buttonStyle(.plain)
            
            Button(action: { showingClearConfirmation = true }) {
               HStack {
                  Image(systemName: "trash")
                  Text(L10n.clearAllApps)
                  Spacer()
               }
               .padding(.horizontal, 16)
               .padding(.vertical, 10)
               .background(Color.red.opacity(0.1))
               .foregroundColor(.red)
               .cornerRadius(8)
            }
            .buttonStyle(.plain)
         }
         
         VStack(alignment: .leading, spacing: 12) {
            Text(L10n.applicationControl)
               .font(.headline)
               .foregroundColor(.primary)
            
            Button(action: forceQuitApp) {
               HStack {
                  Image(systemName: "power")
                  Text(L10n.forceQuit)
                  Spacer()
               }
               .padding(.horizontal, 16)
               .padding(.vertical, 10)
               .background(Color.orange.opacity(0.1))
               .foregroundColor(.orange)
               .cornerRadius(8)
            }
            .buttonStyle(.plain)
         }
         
      }
      .padding(.horizontal, 8)
      .alert(L10n.clearAllAppsTitle, isPresented: $showingClearConfirmation) {
         Button(L10n.cancel, role: .cancel) { }
         Button(L10n.clear, role: .destructive) {
            clearGridItems()
         }
      } message: {
         Text(L10n.clearAllAppsMessage)
      }
   }
   
   private func exportLayout() {
      appManager.exportLayout()
   }
   
   private func importLayout() {
      appManager.importLayout(appsPerPage: settingsManager.settings.appsPerPage)
   }
   
   private func clearGridItems() {
      appManager.clearGridItems(appsPerPage: settingsManager.settings.appsPerPage)
   }
   
   private func forceQuitApp() {
      NSApplication.shared.terminate(nil)
   }
}
