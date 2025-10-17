import SwiftUI

struct WindowAccessor: NSViewRepresentable {
   func makeNSView(context: Context) -> NSView {
      let view = NSView()
      DispatchQueue.main.async {
         guard let currentWindow = view.window else { return }

         let newWindow = ResponsiveWindow(
            contentRect: currentWindow.frame,
            styleMask: currentWindow.styleMask,
            backing: .buffered,
            defer: false
         )

         newWindow.contentView = currentWindow.contentView
         newWindow.titleVisibility = .hidden
         newWindow.styleMask.remove([.resizable, .titled])
         newWindow.level = .floating
         newWindow.setFrame(NSScreen.main?.frame ?? .zero, display: true)
         newWindow.makeKeyAndOrderFront(nil)

         currentWindow.close()
      }
      return view
   }
   
   func updateNSView(_ nsView: NSView, context: Context) {}

   final class ResponsiveWindow: NSWindow {
      override var canBecomeKey: Bool { true }
      override var canBecomeMain: Bool { true }
      override var acceptsFirstResponder: Bool { true }
   }
}
