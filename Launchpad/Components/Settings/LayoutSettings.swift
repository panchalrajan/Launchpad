import SwiftUI

struct LayoutSettings: View {
   @Binding var settings: LaunchpadSettings
   
   var body: some View {
      ScrollView {
         VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
               Text(L10n.layout)
                  .font(.headline)
                  .foregroundColor(.primary)
               
               HStack(spacing: 24) {
                  VStack(alignment: .leading, spacing: 8) {
                     Text(L10n.columns)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                     
                     HStack {
                        TextField(L10n.columns, value: $settings.columns, format: .number)
                           .textFieldStyle(.roundedBorder)
                           .frame(width: 60)
                        
                        Stepper("", value: $settings.columns, in: 2...20)
                           .labelsHidden()
                     }
                  }
                  
                  VStack(alignment: .leading, spacing: 8) {
                     Text(L10n.rows)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                     
                     HStack {
                        TextField(L10n.rows, value: $settings.rows, format: .number)
                           .textFieldStyle(.roundedBorder)
                           .frame(width: 60)
                        
                        Stepper("", value: $settings.rows, in: 2...15)
                           .labelsHidden()
                     }
                  }
                  
                  VStack(alignment: .leading, spacing: 8) {
                     Text(L10n.folderColumns)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                     
                     HStack {
                        TextField(L10n.folderColumns, value: $settings.folderColumns, format: .number)
                           .textFieldStyle(.roundedBorder)
                           .frame(width: 60)
                        
                        Stepper("", value: $settings.folderColumns, in: 2...8)
                           .labelsHidden()
                     }
                  }
                  
                  VStack(alignment: .leading, spacing: 8) {
                     Text(L10n.folderRows)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                     
                     HStack {
                        TextField(L10n.folderRows, value: $settings.folderRows, format: .number)
                           .textFieldStyle(.roundedBorder)
                           .frame(width: 60)
                        
                        Stepper("", value: $settings.folderRows, in: 1...6)
                           .labelsHidden()
                     }
                  }
               }
            }
            
            VStack(alignment: .leading, spacing: 12) {
               Text(L10n.iconSize)
                  .font(.headline)
                  .foregroundColor(.primary)
               
               Slider(
                  value: $settings.iconSize,
                  in: 50...200,
                  step: 10
               ) {
                  
               } minimumValueLabel: {
                  Text(L10n.number10)
                     .font(.caption2)
                     .foregroundColor(.secondary)
               } maximumValueLabel: {
                  Text(L10n.number200)
                     .font(.caption2)
                     .foregroundColor(.secondary)
               }
               .accentColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 12) {
               Text(L10n.dropAnimationDelay)
                  .font(.headline)
                  .foregroundColor(.primary)
               
               Slider(
                  value: $settings.dropDelay,
                  in: 0.0...3.0,
                  step: 0.1
               ) {
               } minimumValueLabel: {
                  Text(L10n.time00s)
                     .font(.caption2)
                     .foregroundColor(.secondary)
               } maximumValueLabel: {
                  Text(L10n.time30s)
                     .font(.caption2)
                     .foregroundColor(.secondary)
               }
               .accentColor(.blue)
            }
            
            
            VStack(alignment: .leading, spacing: 12) {
               Text(L10n.pageScrollDebounce)
                  .font(.headline)
                  .foregroundColor(.primary)
               
               Slider(
                  value: $settings.scrollDebounceInterval,
                  in: 0.0...3.0,
                  step: 0.1
               ) {
               } minimumValueLabel: {
                  Text(L10n.time00s)
                     .font(.caption2)
                     .foregroundColor(.secondary)
               } maximumValueLabel: {
                  Text(L10n.time30s)
                     .font(.caption2)
                     .foregroundColor(.secondary)
               }
               .accentColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 12) {
               Text(L10n.pageScrollThreshold)
                  .font(.headline)
                  .foregroundColor(.primary)
               
               Slider(
                  value: $settings.scrollActivationThreshold,
                  in: 10...200,
                  step: 10
               ) {
               } minimumValueLabel: {
                  Text(L10n.number10)
                     .font(.caption2)
                     .foregroundColor(.secondary)
               } maximumValueLabel: {
                  Text(L10n.number200)
                     .font(.caption2)
                     .foregroundColor(.secondary)
               }
               .accentColor(.blue)
            }
         }
         .padding(.horizontal, 8)
      }
   }
}
