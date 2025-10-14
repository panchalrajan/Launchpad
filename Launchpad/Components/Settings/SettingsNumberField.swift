import SwiftUI

struct SettingsNumberField: View {
   let title: String
   @Binding var value: Int
   let range: ClosedRange<Int>
   
   var body: some View {
      VStack(alignment: .leading, spacing: 8) {
         Text(title)
            .font(.subheadline)
            .foregroundColor(.secondary)
         
         HStack {
            TextField(title, value: $value, format: .number)
               .textFieldStyle(.roundedBorder)
               .frame(width: 60)
            
            Stepper("", value: $value, in: range)
               .labelsHidden()
         }
      }
   }
}
