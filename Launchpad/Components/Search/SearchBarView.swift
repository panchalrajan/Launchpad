import SwiftUI

struct SearchBarView: View {
   var searchText: String
   var transparency: Double
   
   var body: some View {
      HStack {
         Spacer()
         Text(searchText.isEmpty ? L10n.searchPlaceholder : searchText)
            .textFieldStyle(.plain)
            .font(.system(size: 16, weight: .regular))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(width: LaunchPadConstants.searchBarWidth, height: LaunchPadConstants.searchBarHeight)
            .background(
               RoundedRectangle(cornerRadius: 24, style: .continuous)
                  .fill(Color(NSColor.windowBackgroundColor).opacity(0.4 * transparency))
            )
            .shadow(color: Color.black.opacity(0.2 * transparency), radius: 10, x: 0, y: 3)
         Spacer()
      }
      .padding(.top, 40)
   }
}
