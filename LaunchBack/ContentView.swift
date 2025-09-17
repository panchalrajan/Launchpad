import SwiftUI
import AppKit

struct ContentView: View {
    let apps: [AppInfo]
    let columns: Int
    @State private var isVisible = false
    
    var body: some View {
        GeometryReader { geo in
            let layout = LayoutMetrics(size: geo.size, columns: columns)
            
            ScrollView(.horizontal, showsIndicators: false) {
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
        }
        .scaleEffect(isVisible ? 1 : 0.85)
        .opacity(isVisible ? 1 : 0)
        .animation(.easeInOut(duration: 0.3), value: isVisible)
        .onAppear { isVisible = true }
        .onDisappear { isVisible = false }
    }
}

private struct LayoutMetrics {
    let hPadding: CGFloat
    let vPadding: CGFloat
    let spacing: CGFloat
    let cellWidth: CGFloat
    let iconSize: CGFloat
    let fontSize: CGFloat
    
    init(size: CGSize, columns: Int) {
        let aspect = size.width / size.height
        
        hPadding = size.width * 0.06
        vPadding = aspect > 2.0 ? 0 : (size.height < 800 ? size.height * 0.05 : size.height * 0.08)
        spacing = aspect > 2.0 ? size.height * 0.02 : (size.height < 800 ? size.height * 0.04 : size.height * 0.03)
        
        let totalSpacing = CGFloat(columns - 1) * spacing
        cellWidth = (size.width - (hPadding * 2) - totalSpacing) / CGFloat(columns)
        iconSize = cellWidth * 0.6
        fontSize = max(10, cellWidth * 0.04)
    }
}
