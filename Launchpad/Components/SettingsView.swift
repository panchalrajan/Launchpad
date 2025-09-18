import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsManager = SettingsManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempColumns: Int
    @State private var tempRows: Int
    @State private var tempIconSizeMultiplier: Double
    @State private var tempDropDelay: Double
    
    init() {
        let currentSettings = SettingsManager.shared.settings
        _tempColumns = State(initialValue: currentSettings.columns)
        _tempRows = State(initialValue: currentSettings.rows)
        _tempIconSizeMultiplier = State(initialValue: currentSettings.iconSize)
        _tempDropDelay = State(initialValue: currentSettings.dropDelay)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Launchpad Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button("✕") {
                    dismiss()
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                .font(.title3)
            }
            .padding(.bottom, 10)
            
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Grid Layout")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Columns")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                TextField("Columns", value: $tempColumns, format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 60)
                                
                                Stepper("", value: $tempColumns, in: 2...20)
                                    .labelsHidden()
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Rows")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                TextField("Rows", value: $tempRows, format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 60)
                                
                                Stepper("", value: $tempRows, in: 2...15)
                                    .labelsHidden()
                            }
                        }
                    }
                }
                
                // Icon Size Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Icon Size")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Size")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(Int(tempIconSizeMultiplier * 100))%")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(
                            value: $tempIconSizeMultiplier,
                            in: 0.3...1.0,
                            step: 0.05
                        ) {
                            Text("Icon Size")
                        } minimumValueLabel: {
                            Text("30%")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        } maximumValueLabel: {
                            Text("100%")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .accentColor(.blue)
                    }
                }
                
                // Drop Delay Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Drop Animation Delay")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Delay")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(String(format: "%.1fs", tempDropDelay))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(
                            value: $tempDropDelay,
                            in: 0.0...3.0,
                            step: 0.1
                        ) {
                            Text("Drop Delay")
                        } minimumValueLabel: {
                            Text("0.0s")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        } maximumValueLabel: {
                            Text("3.0s")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .accentColor(.blue)
                    }
                }
            }
            .padding(.horizontal, 4)
            
            Spacer()
            
            HStack(spacing: 12) {
                Button("Reset to Defaults") {
                    tempColumns = LaunchpadSettings.defaultColumns
                    tempRows = LaunchpadSettings.defaultRows
                    tempIconSizeMultiplier = LaunchpadSettings.defaultIconSize
                    tempDropDelay = LaunchpadSettings.defaultDropDelay
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Button("Apply") {
                    settingsManager.updateSettings(columns: tempColumns, rows: tempRows, iconSize: tempIconSizeMultiplier, dropDelay: tempDropDelay)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(width: 350, height: 360)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
}
