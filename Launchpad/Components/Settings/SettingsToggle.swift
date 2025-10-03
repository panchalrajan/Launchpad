import SwiftUI

struct SettingsToggle: View {
   let title: String
   @Binding var isOn: Bool
   
   var body: some View {
      HStack {
         Text(title)
            .font(.headline)
            .foregroundColor(.primary)
         
         Spacer()
         
         Toggle("", isOn: $isOn)
            .labelsHidden()
            .toggleStyle(SwitchToggleStyle())
      }
   }
}
