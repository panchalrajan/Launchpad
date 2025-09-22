import AppKit
import SwiftUI

struct EmptySearchView: View {
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    VStack {
      Spacer()
      Image(systemName: "magnifyingglass")
        .font(.system(size: 48))
        .foregroundColor(colorScheme == .dark ? .gray.opacity(0.8) : .gray)
      Text("No apps found")
        .font(.title2)
        .foregroundColor(colorScheme == .dark ? .gray.opacity(0.8) : .gray)
        .padding(.top, 10)
      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
