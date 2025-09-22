import SwiftUI

struct PageIndicatorView: View {
  @Binding var currentPage: Int
  let pageCount: Int
  let isFolderOpen: Bool
  let searchText: String
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    HStack(spacing: 16) {
      ForEach(0..<pageCount, id: \.self) { index in
        Circle()
          .fill(
            index == currentPage
              ? (colorScheme == .dark ? Color.white : Color.primary)
              : (colorScheme == .dark ? Color.gray.opacity(0.4) : Color.gray.opacity(0.6))
          )
          .frame(width: 8, height: 8)
          .scaleEffect(index == currentPage ? 1.2 : 1.0)
          .animation(.easeInOut(duration: 0.2), value: currentPage)
          .onTapGesture {
            if !isFolderOpen {
              withAnimation(.interpolatingSpring(stiffness: 300, damping: 100)) {
                currentPage = index
              }
            }
          }
      }
    }
    .padding(.top, 16)
    .padding(.bottom, 120)
    .opacity(searchText.isEmpty && !isFolderOpen ? 1 : 0)
  }
}
