import AppKit
import SwiftUI

struct SearchField: NSViewRepresentable {
  @Binding var text: String
  var onEnterPressed: (() -> Void)

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  func makeNSView(context: Context) -> NSSearchField {
    let searchField = NSSearchField()
    searchField.delegate = context.coordinator
    searchField.focusRingType = .none
    searchField.bezelStyle = .roundedBezel
    searchField.placeholderString = L10n.searchPlaceholder
    searchField.font = NSFont.systemFont(ofSize: 16, weight: .regular)
    searchField.alphaValue = 0.7

    if let cell = searchField.cell as? NSSearchFieldCell {
      cell.controlSize = .large
      cell.usesSingleLineMode = true
      cell.wraps = false
      cell.isScrollable = true
    }

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

extension SearchField {
  final class Coordinator: NSObject, NSSearchFieldDelegate {
    private let parent: SearchField

    init(_ parent: SearchField) {
      self.parent = parent
    }

    func controlTextDidChange(_ obj: Notification) {
      guard let field = obj.object as? NSSearchField else { return }
      parent.text = field.stringValue
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
      // Launch first search result on Enter key press
      if commandSelector == #selector(NSResponder.insertNewline(_:)) {
        parent.onEnterPressed()
        return true
      }
      return false
    }
  }
}
