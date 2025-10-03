import SwiftUI

struct FeaturesSettings: View {
    @Binding var settings: LaunchpadSettings
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                
                SettingsToggle(
                    title: L10n.showDock,
                    isOn: $settings.showDock
                )
            }
        }
        .padding(.horizontal, 8)
    }
}
