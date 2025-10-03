import SwiftUI

struct PageIndicatorView: View {
    
    @Binding var currentPage: Int
    let pageCount: Int
    let isFolderOpen: Bool
    let searchText: String
    let transparency: Double
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: LaunchPadConstants.pageIndicatorSpacing) {
            ForEach(0..<pageCount, id: \.self) { index in
                Circle()
                    .fill(
                        index == currentPage
                        ? (colorScheme == .dark ? Color.white : Color.primary)
                        : (colorScheme == .dark ? Color.gray.opacity(0.4 * transparency) : Color.gray.opacity(0.6 * transparency))
                    )
                    .frame(width: LaunchPadConstants.pageIndicatorSize, height: LaunchPadConstants.pageIndicatorSize)
                    .scaleEffect(index == currentPage ? LaunchPadConstants.pageIndicatorActiveScale : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
                    .onTapGesture {
                        withAnimation(LaunchPadConstants.springAnimation) {
                            currentPage = index
                        }
                    }
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 40)
        .opacity(searchText.isEmpty && !isFolderOpen ? 1 : 0)
    }
}
