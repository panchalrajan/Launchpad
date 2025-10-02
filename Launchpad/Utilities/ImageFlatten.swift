import AppKit

extension NSImage {
    // Rasterize the image into a single bitmap rep so it won’t switch designs at small sizes.
    func flattenedForConsistency(targetPixelSize: CGFloat = LaunchPadConstants.iconFlattenSize) -> NSImage {
        let size = NSSize(width: targetPixelSize, height: targetPixelSize)
        var rect = NSRect(origin: .zero, size: size)
        guard let cg = self.cgImage(forProposedRect: &rect, context: nil, hints: nil) else {
            // Fallback to the largest existing bitmap rep if cgImage fails
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
        let rep = NSBitmapImageRep(cgImage: cg)
        rep.size = size
        let image = NSImage(size: size)
        image.addRepresentation(rep)
        image.isTemplate = false
        return image
    }
}
