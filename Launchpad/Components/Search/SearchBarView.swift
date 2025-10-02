import SwiftUI

struct SearchBarView: View {
   @Binding var searchText: String

   var body: some View {
      HStack {
         Spacer()
         SearchField(text: $searchText)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(width: LaunchPadConstants.searchBarWidth, height: LaunchPadConstants.searchBarHeight)
            .background(
               RoundedRectangle(cornerRadius: 24, style: .continuous)
                  .fill(Color(NSColor.windowBackgroundColor).opacity(0.4))
            )
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 3)
         Spacer()
      }
      .padding(.top, 40)
      .padding(.bottom, 24)
   }
}
