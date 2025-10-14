import SwiftUI

struct WindowAccessor: NSViewRepresentable {
   func makeNSView(context: Context) -> NSView {
      let view = NSView()
      DispatchQueue.main.async {
         guard let window = view.window else { return }
         window.titleVisibility = .hidden
         window.styleMask.remove([.resizable, .titled])
         window.level = .floating
         window.setFrame(NSScreen.main?.frame ?? .zero, display: true)
      }
      return view
   }
   
   func updateNSView(_ nsView: NSView, context: Context) {}
}
