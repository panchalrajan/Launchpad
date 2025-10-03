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
        }
        .padding(.horizontal, 8)
    }
}
