import SwiftUI
import AppKit

struct AppIconView: View {
    let app: AppInfo

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 10) {
                Image(nsImage: app.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geo.size.width * 0.6, height: geo.size.width * 0.6)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                Text(app.name)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: geo.size.width)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                NSWorkspace.shared.open(URL(fileURLWithPath: app.path))
                NSApp.terminate(nil)
            }
        }
        .frame(height: 110)
    }
}
