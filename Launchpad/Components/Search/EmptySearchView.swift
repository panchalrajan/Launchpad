import AppKit
import SwiftUI

struct EmptySearchView: View {
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.8))
            Text("No apps found")
                .font(.title2)
                .foregroundColor(.gray.opacity(0.8))
                .padding(.top, 10)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
