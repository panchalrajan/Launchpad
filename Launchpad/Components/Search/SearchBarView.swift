import SwiftUI

struct SearchBarView: View {
   @Binding var searchText: String
   var transparency: Double
   var onClear: () -> Void
   @FocusState private var isFocused: Bool

   var body: some View {
      HStack {
         Spacer()

         HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
               .foregroundColor(.secondary)
               .font(.system(size: 14))

            TextField(L10n.searchPlaceholder, text: $searchText)
               .textFieldStyle(.plain)
               .font(.system(size: 16, weight: .regular))
               .focused($isFocused)
               .tint(.gray)

            if !searchText.isEmpty {
               Button(action: {
                  onClear()
                  isFocused = true
               }) {
                  Image(systemName: "xmark.circle.fill")
                     .foregroundColor(.secondary)
                     .font(.system(size: 14))
               }
               .buttonStyle(.plain)
               .keyboardShortcut(.cancelAction)
            }
         }
         .padding(.horizontal, 12)
         .padding(.vertical, 6)
         .frame(width: LaunchPadConstants.searchBarWidth, height: LaunchPadConstants.searchBarHeight)
         .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
               .fill(Color(NSColor.windowBackgroundColor).opacity(0.4 * transparency))
         )
         .shadow(color: Color.black.opacity(0.2 * transparency), radius: 10, x: 0, y: 3)

         Spacer()
      }
      .padding(.top, 40)
      .onAppear {
         isFocused = true
      }
   }
}
