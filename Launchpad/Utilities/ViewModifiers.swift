import SwiftUI

struct FadeInScaleViewModifier: ViewModifier {
  let isVisible: Bool
  let duration: Double

  init(isVisible: Bool, duration: Double = 0.3) {
    self.isVisible = isVisible
    self.duration = duration
  }

  func body(content: Content) -> some View {
    content
      .scaleEffect(isVisible ? 1 : 0.85)
      .opacity(isVisible ? 1 : 0)
      .animation(.easeInOut(duration: duration), value: isVisible)
  }
}

extension View {
  func fadeInScale(isVisible: Bool, duration: Double = 0.3) -> some View {
    modifier(FadeInScaleViewModifier(isVisible: isVisible, duration: duration))
  }
}
