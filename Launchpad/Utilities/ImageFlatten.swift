import AppKit

extension NSImage {
   func flattenedForConsistency(targetPixelSize: CGFloat = LaunchPadConstants.iconDisplaySize) -> NSImage {
      if let rep = self.representations
         .compactMap({ $0 as? NSBitmapImageRep })
         .max(by: { $0.pixelsWide * $0.pixelsHigh < $1.pixelsWide * $1.pixelsHigh }) {
         let image = NSImage(size: NSSize(width: rep.pixelsWide, height: rep.pixelsHigh))
         image.addRepresentation(rep)
         image.isTemplate = false
         return image
      }
      return self
   }
}
