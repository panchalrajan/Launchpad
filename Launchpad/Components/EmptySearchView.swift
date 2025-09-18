import SwiftUI
import AppKit

struct EmptySearchView: View {
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("No apps found")
                .font(.title2)
                .foregroundColor(.gray)
                .padding(.top, 10)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
