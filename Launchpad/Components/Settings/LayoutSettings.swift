import SwiftUI

struct LayoutSettings: View {
    var settingsManager = SettingsManager.shared
    
    @Binding var tempColumns: Int
    @Binding var tempRows: Int
    @Binding var tempIconSize: Double
    @Binding var tempDropDelay: Double
    @Binding var tempFolderColumns: Int
    @Binding var tempFolderRows: Int
    @Binding var tempScrollDebounceInterval: Double
    @Binding var tempScrollActivationThreshold: Double
    
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
                                TextField(L10n.columns, value: $tempColumns, format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 60)
                                
                                Stepper("", value: $tempColumns, in: 2...20)
                                    .labelsHidden()
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(L10n.rows)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                TextField(L10n.rows, value: $tempRows, format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 60)
                                
                                Stepper("", value: $tempRows, in: 2...15)
                                    .labelsHidden()
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(L10n.folderColumns)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                TextField(L10n.folderColumns, value: $tempFolderColumns, format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 60)
                                
                                Stepper("", value: $tempFolderColumns, in: 2...8)
                                    .labelsHidden()
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(L10n.folderRows)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                TextField(L10n.folderRows, value: $tempFolderRows, format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 60)
                                
                                Stepper("", value: $tempFolderRows, in: 1...6)
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
                        value: $tempIconSize,
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
                        value: $tempDropDelay,
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
                        value: $tempScrollDebounceInterval,
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
                        value: $tempScrollActivationThreshold,
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
