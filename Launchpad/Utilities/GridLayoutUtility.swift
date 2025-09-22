import SwiftUI

struct GridLayoutUtility {
  static func createGridColumns(count: Int, cellWidth: CGFloat, spacing: CGFloat) -> [GridItem] {
    Array(repeating: GridItem(.fixed(cellWidth), spacing: spacing), count: count)
  }

  static func createFlexibleGridColumns(count: Int, spacing: CGFloat = 0) -> [GridItem] {
    Array(repeating: GridItem(.flexible(), spacing: spacing, alignment: .top), count: count)
  }
}
