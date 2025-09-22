import SwiftUI

struct SearchBarView: View {
  @Binding var searchText: String
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    HStack {
      Spacer()
      SearchField(text: $searchText)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .frame(width: 480, height: 36)
        .background(
          RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(Color(NSColor.windowBackgroundColor).opacity(0.4))
        )
        .shadow(
          color: colorScheme == .dark
            ? Color.black.opacity(0.2)
            : Color.black.opacity(0.1),
          radius: 10, x: 0, y: 3
        )
      Spacer()
    }
    .padding(.top, 40)
    .padding(.bottom, 24)
  }
}
