import AppKit
import SwiftUI

struct LayoutMetrics {
  let hPadding: CGFloat
  let vPadding: CGFloat
  let spacing: CGFloat
  let cellWidth: CGFloat
  let iconSize: CGFloat
  let fontSize: CGFloat

  init(size: CGSize, columns: Int, iconSize: Double) {
    let aspect = size.width / size.height

    hPadding = size.width * 0.06
    vPadding = aspect > 2.0 ? 0 : (size.height < 800 ? size.height * 0.05 : size.height * 0.08)
    spacing = aspect > 2.0 ? size.height * 0.02 : (size.height < 800 ? size.height * 0.04 : size.height * 0.03)

    let totalSpacing = CGFloat(columns - 1) * spacing
    cellWidth = (size.width - (hPadding * 2) - totalSpacing) / CGFloat(columns)
    self.iconSize = iconSize
    fontSize = max(10, cellWidth * 0.04)
  }
}
