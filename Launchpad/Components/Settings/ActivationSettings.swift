import SwiftUI

struct ActivationSettings: View {
    @Binding var settings: LaunchpadSettings
    
    @State private var enteredProductKey: String = ""
    @State private var showValidationMessage = false
    @State private var validationMessage = ""
    @State private var isValid = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.activationStatus)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Image(systemName: settings.isActivated ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(settings.isActivated ? .green : .orange)
                        .font(.title2)
                    
                    Text(settings.isActivated ? L10n.activated : L10n.notActivated)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(settings.isActivated ? .green : .orange)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill((settings.isActivated ? Color.green : Color.orange).opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke((settings.isActivated ? Color.green : Color.orange).opacity(0.3), lineWidth: 1)
                        )
                )
            }
            
            if !settings.isActivated {
                VStack(alignment: .leading, spacing: 12) {
                    Text(L10n.productKey)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField(L10n.enterProductKey, text: $enteredProductKey)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                        .onChange(of: enteredProductKey) { _, _ in
                            showValidationMessage = false
                        }
                    
                    Button(action: validateAndActivate) {
                        HStack {
                            Image(systemName: "key.fill")
                            Text(L10n.activate)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    
                    if showValidationMessage {
                        HStack {
                            Image(systemName: isValid ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .foregroundColor(isValid ? .green : .red)
                            Text(validationMessage)
                                .font(.subheadline)
                                .foregroundColor(isValid ? .green : .red)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill((isValid ? Color.green : Color.red).opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke((isValid ? Color.green : Color.red).opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .onAppear {
            enteredProductKey = settings.productKey
        }
    }
    
    private func validateAndActivate() {
        let trimmedKey = enteredProductKey.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedKey == LaunchPadConstants.productKey {
            settings.productKey = trimmedKey
            isValid = true
            validationMessage = L10n.activationSuccessful
            showValidationMessage = true
        } else {
            isValid = false
            validationMessage = L10n.invalidProductKey
            showValidationMessage = true
        }
    }
}
