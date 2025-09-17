import SwiftUI
import AppKit

struct AutoFocusSearchField: NSViewRepresentable {
    @Binding var text: String

    class Coordinator: NSObject, NSSearchFieldDelegate {
        var parent: AutoFocusSearchField
        init(_ parent: AutoFocusSearchField) {
            self.parent = parent
        }
        func controlTextDidChange(_ obj: Notification) {
            if let field = obj.object as? NSSearchField {
                parent.text = field.stringValue
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSSearchField {
        let searchField = NSSearchField(string: "")
        searchField.delegate = context.coordinator
        searchField.focusRingType = .none
        searchField.bezelStyle = .roundedBezel
        searchField.placeholderString = "Search"
        searchField.cell?.wraps = false
        searchField.cell?.isScrollable = true

        // Increase intrinsic height by using a larger font and vertical padding
        searchField.font = NSFont.systemFont(ofSize: 16, weight: .regular)
        if let cell = searchField.cell as? NSSearchFieldCell {
            // Increase vertical padding to make the field taller
            cell.controlSize = .large
            cell.usesSingleLineMode = true
        }

        // Add a hard height constraint to ensure the AppKit view is tall
        let heightConstraint = searchField.heightAnchor.constraint(greaterThanOrEqualToConstant: 144)
        heightConstraint.priority = .required
        heightConstraint.isActive = true

        DispatchQueue.main.async {
            searchField.becomeFirstResponder()
        }
        return searchField
    }

    func updateNSView(_ nsView: NSSearchField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
    }
}
