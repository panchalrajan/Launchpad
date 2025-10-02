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
                  SettingsNumberField(title: L10n.columns, value: $settings.columns, range: 2...20)
                  SettingsNumberField(title: L10n.rows, value: $settings.rows, range: 2...15)
                  SettingsNumberField(title: L10n.folderColumns, value: $settings.folderColumns, range: 2...8)
                  SettingsNumberField(title: L10n.folderRows, value: $settings.folderRows, range: 1...6)
               }
            }
            
            SettingsSlider(
               title: L10n.iconSize,
               value: $settings.iconSize,
               range: 50...200,
               step: 10,
               minLabel: L10n.number10,
               maxLabel: L10n.number200
            )
            
            SettingsSlider(
               title: L10n.dropAnimationDelay,
               value: $settings.dropDelay,
               range: 0.0...3.0,
               step: 0.1,
               minLabel: L10n.time00s,
               maxLabel: L10n.time30s
            )
            
            
            SettingsSlider(
               title: L10n.pageScrollDebounce,
               value: $settings.scrollDebounceInterval,
               range: 0.0...3.0,
               step: 0.1,
               minLabel: L10n.time00s,
               maxLabel: L10n.time30s
            )
            
            SettingsSlider(
               title: L10n.pageScrollThreshold,
               value: $settings.scrollActivationThreshold,
               range: 10...200,
               step: 10,
               minLabel: L10n.number10,
               maxLabel: L10n.number200
            )
         }
         .padding(.horizontal, 8)
      }
   }
}
