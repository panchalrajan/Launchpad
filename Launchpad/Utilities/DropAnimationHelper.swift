import SwiftUI

@MainActor
struct DropAnimationHelper {
  static func performDelayedMove(
    delay: Double,
    animation: Animation = .easeInOut(duration: 0.2),
    action: @escaping () -> Void
  ) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
      withAnimation(animation) {
        action()
      }
    }
  }

  static func calculateMoveOffset(fromIndex: Int, toIndex: Int) -> Int {
    return toIndex > fromIndex ? toIndex + 1 : toIndex
  }
}
