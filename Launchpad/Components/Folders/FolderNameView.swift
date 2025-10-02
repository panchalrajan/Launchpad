import AppKit
import SwiftUI

struct FolderNameView: View {
   @Binding var folder: Folder?
   @Binding var editingName: Bool

   let opacity: Double
   let offset: CGFloat

   var body: some View {
      VStack(spacing: 16) {
         HStack {
            Spacer()
            if editingName {
               TextField(L10n.folderNamePlaceholder, text: Binding(get: { folder!.name }, set: { folder!.name = $0 }))
                  .textFieldStyle(.plain)
                  .font(.title2.weight(.medium))
                  .multilineTextAlignment(.center)
                  .padding(.horizontal, 20)
                  .padding(.vertical, 8)
                  .background(
                     RoundedRectangle(cornerRadius: 8)
                        .fill(Color.primary.opacity(0.08))
                        .overlay(
                           RoundedRectangle(cornerRadius: 8)
                              .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                        )
                  )
                  .onSubmit {
                     withAnimation(.easeOut(duration: 0.2)) {
                        editingName = false
                     }
                  }
            } else {
               Text(folder?.name ?? "")
                  .font(.title2.weight(.medium))
                  .foregroundStyle(.primary)
                  .padding(.horizontal, 16)
                  .padding(.vertical, 8)
                  .onTapGesture {
                     withAnimation(.easeOut(duration: 0.2)) {
                        editingName = true
                     }
                  }
            }
            Spacer()
         }
         .padding(.horizontal, 32)
      }
      .offset(y: offset)
      .opacity(opacity)
      .padding(.vertical, 20)
   }
}
