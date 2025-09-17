import SwiftUI
import AppKit

struct AutoFocusSearchField: NSViewRepresentable {
    @Binding var text: String

    class Coordinator: NSObject, NSSearchFieldDelegate {
        var parent: AutoFocusSearchField
        init(_ parent: AutoFocusSearchField) { self.parent = parent }
        func controlTextDidChange(_ obj: Notification) {
            guard let field = obj.object as? NSSearchField else { return }
            parent.text = field.stringValue
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
        searchField.font = NSFont.systemFont(ofSize: 16, weight: .regular)
        if let cell = searchField.cell as? NSSearchFieldCell {
            cell.controlSize = .large
            cell.usesSingleLineMode = true
        }
        let heightConstraint = searchField.heightAnchor.constraint(greaterThanOrEqualToConstant: 144)
        heightConstraint.priority = .required
        heightConstraint.isActive = true
        DispatchQueue.main.async { searchField.becomeFirstResponder() }
        return searchField
    }

    func updateNSView(_ nsView: NSSearchField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
    }
}
