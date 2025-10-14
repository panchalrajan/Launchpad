import SwiftUI

struct SettingsSlider: View {
   let title: String
   @Binding var value: Double
   let range: ClosedRange<Double>
   let step: Double
   let minLabel: String
   let maxLabel: String
   
   var body: some View {
      VStack(alignment: .leading, spacing: 12) {
         Text(title)
            .font(.headline)
            .foregroundColor(.primary)
         
         Slider(
            value: $value,
            in: range,
            step: step
         ) {
            
         } minimumValueLabel: {
            Text(minLabel)
               .font(.caption2)
               .foregroundColor(.secondary)
         } maximumValueLabel: {
            Text(maxLabel)
               .font(.caption2)
               .foregroundColor(.secondary)
         }
         .accentColor(.blue)
      }
   }
}
