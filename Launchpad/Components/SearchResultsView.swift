import SwiftUI
import AppKit

struct SearchResultsView: View {
    let apps: [AppInfo]
    let columns: Int
    @State private var isVisible = false
    
    var body: some View {
        GeometryReader { geo in
            let layout = LayoutMetrics(size: geo.size, columns: columns)
            
            if apps.isEmpty {
                // No search results found
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
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.fixed(layout.cellWidth), spacing: layout.spacing), count: columns),
                        spacing: layout.spacing
                    ) {
                        ForEach(apps) { app in
                            VStack(spacing: 10) {
                                Image(nsImage: app.icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: layout.iconSize, height: layout.iconSize)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                Text(app.name)
                                    .font(.system(size: layout.fontSize))
                                    .multilineTextAlignment(.center)
                                    .frame(width: layout.cellWidth)
                            }
                            .onTapGesture {
                                NSWorkspace.shared.open(URL(fileURLWithPath: app.path))
                                NSApp.terminate(nil)
                            }
                        }
                    }
                    .padding(.horizontal, layout.hPadding)
                    .padding(.vertical, layout.vPadding)
                }
                .onTapGesture {
                    NSApp.terminate(nil)
                }
            }
        }
        .scaleEffect(isVisible ? 1 : 0.85)
        .opacity(isVisible ? 1 : 0)
        .animation(.easeInOut(duration: 0.3), value: isVisible)
        .onAppear { isVisible = true }
        .onDisappear { isVisible = false }
    }
}
