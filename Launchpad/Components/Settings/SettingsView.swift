import SwiftUI

struct SettingsView: View {
  var settingsManager = SettingsManager.shared
  @Environment(\.dismiss) private var dismiss

  @State private var tempColumns: Int
  @State private var tempRows: Int
  @State private var tempIconSize: Double
  @State private var tempDropDelay: Double
  @State private var tempFolderColumns: Int
  @State private var tempFolderRows: Int
  @Environment(\.colorScheme) private var colorScheme

  init() {
    let currentSettings = SettingsManager.shared.settings
    _tempColumns = State(initialValue: currentSettings.columns)
    _tempRows = State(initialValue: currentSettings.rows)
    _tempIconSize = State(initialValue: currentSettings.iconSize)
    _tempDropDelay = State(initialValue: currentSettings.dropDelay)
    _tempFolderColumns = State(initialValue: currentSettings.folderColumns)
    _tempFolderRows = State(initialValue: currentSettings.folderRows)
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
      .padding(.bottom, 16)

      VStack(alignment: .leading, spacing: 20) {
        VStack(alignment: .leading, spacing: 12) {
          Text("Grid Layout")
            .font(.headline)
            .foregroundColor(.primary)

          HStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
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

        VStack(alignment: .leading, spacing: 12) {
          Text("Folder Grid Layout")
            .font(.headline)
            .foregroundColor(.primary)

          HStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
              Text("Folder Columns")
                .font(.subheadline)
                .foregroundColor(.secondary)

              HStack {
                TextField("Folder Columns", value: $tempFolderColumns, format: .number)
                  .textFieldStyle(.roundedBorder)
                  .frame(width: 60)

                Stepper("", value: $tempFolderColumns, in: 2...8)
                  .labelsHidden()
              }
            }

            VStack(alignment: .leading, spacing: 4) {
              Text("Folder Rows")
                .font(.subheadline)
                .foregroundColor(.secondary)

              HStack {
                TextField("Folder Rows", value: $tempFolderRows, format: .number)
                  .textFieldStyle(.roundedBorder)
                  .frame(width: 60)

                Stepper("", value: $tempFolderRows, in: 1...6)
                  .labelsHidden()
              }
            }
          }
        }

        VStack(alignment: .leading, spacing: 12) {
          Text("Icon Size")
            .font(.headline)
            .foregroundColor(.primary)

          Slider(
            value: $tempIconSize,
            in: 20...200,
            step: 10
          ) {

          } minimumValueLabel: {
            Text("10")
              .font(.caption2)
              .foregroundColor(.secondary)
          } maximumValueLabel: {
            Text("200")
              .font(.caption2)
              .foregroundColor(.secondary)
          }
          .accentColor(.blue)
        }

        VStack(alignment: .leading, spacing: 12) {
          Text("Drop Animation Delay")
            .font(.headline)
            .foregroundColor(.primary)

          Slider(
            value: $tempDropDelay,
            in: 0.0...3.0,
            step: 0.1
          ) {
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
      .padding(.horizontal, 8)

      Spacer()

      HStack(spacing: 16) {
        Button("Reset to Defaults") {
          tempColumns = LaunchpadSettings.defaultColumns
          tempRows = LaunchpadSettings.defaultRows
          tempIconSize = LaunchpadSettings.defaultIconSize
          tempDropDelay = LaunchpadSettings.defaultDropDelay
          tempFolderColumns = LaunchpadSettings.defaultFolderColumns
          tempFolderRows = LaunchpadSettings.defaultFolderRows
        }
        .buttonStyle(.bordered)

        Spacer()

        Button("Cancel") {
          dismiss()
        }
        .buttonStyle(.bordered)

        Button("Apply") {
          settingsManager.updateSettings(
            columns: tempColumns,
            rows: tempRows,
            iconSize: tempIconSize,
            dropDelay: tempDropDelay,
            folderColumns: tempFolderColumns,
            folderRows: tempFolderRows)
          dismiss()
        }
        .buttonStyle(.borderedProminent)
      }
    }
    .padding(24)
    .frame(width: 350, height: 360)
    .background(
      colorScheme == .dark
        ? Color(NSColor.windowBackgroundColor)
        : Color(NSColor.controlBackgroundColor)
    )
    .cornerRadius(16)
    .shadow(
      color: colorScheme == .dark
        ? Color.black.opacity(0.5)
        : Color.black.opacity(0.2),
      radius: 20, x: 0, y: 10
    )
  }
}
