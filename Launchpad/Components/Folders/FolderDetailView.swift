import Foundation
import SwiftUI

struct FolderDetailView: View {
    @Binding var pages: [[AppGridItem]]
    @Binding var folder: Folder?
    let settings: LaunchpadSettings
    
    @State private var editingName = false
    @State private var draggedApp: AppInfo?
    @State private var isAnimatingIn = false
    @State private var contentOpacity: Double = 0
    @State private var headerOffset: CGFloat = -20
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        if folder != nil {
            ZStack {
                Color.clear
                    .contentShape(Rectangle())
                    .onDrop(
                        of: [.text],
                        delegate: FolderRemoveDropDelegate(folder: Binding(get: { folder! }, set: { folder = $0 }), draggedApp: $draggedApp, onRemoveApp: addAppToPage)
                    )
                    .onTapGesture {
                        dismissWithAnimation()
                    }
                
                // Main folder container
                VStack(spacing: 10) {
                    // Header Section
                    VStack(spacing: 16) {                        
                        // Folder name
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
                                Text(folder!.name)
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
                    .offset(y: headerOffset)
                    .opacity(contentOpacity)
                    .padding(.vertical, 20)
                    
                    // Content Section
                    GeometryReader { geo in
                        let layout = LayoutMetrics(size: geo.size, columns: settings.folderColumns, rows: settings.folderRows, iconSize: settings.iconSize)
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVGrid(
                                columns: GridLayoutUtility.createGridColumns(count: settings.folderColumns, cellWidth: layout.cellWidth, spacing: layout.hSpacing),
                                spacing: layout.vSpacing
                            ) {
                                ForEach(folder!.apps) { app in
                                    AppIconView(app: app, layout: layout, isDragged: draggedApp?.id == app.id)
                                        .scaleEffect(draggedApp?.id == app.id ? 0.95 : 1.0)
                                        .opacity(draggedApp?.id == app.id ? 0.7 : 1.0)
                                        .animation(.easeOut(duration: 0.15), value: draggedApp?.id == app.id)
                                        .onDrag {
                                            withAnimation(.easeOut(duration: 0.15)) {
                                                draggedApp = app
                                            }
                                            return NSItemProvider(object: app.id.uuidString as NSString)
                                        }
                                        .onDrop(
                                            of: [.text],
                                            delegate: FolderDropDelegate(
                                                folder: Binding(get: { self.folder! }, set: { self.folder = $0 }),
                                                draggedApp: $draggedApp,
                                                dropDelay: settings.dropDelay,
                                                targetApp: app
                                            ))
                                }
                            }
                            .padding(.horizontal, 32)
                            .padding(.vertical, 20)
                        }
                        .scrollBounceBehavior(.basedOnSize)
                    }
                    .opacity(contentOpacity)
                }
                .frame(width: 1200, height: 800)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.regularMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(colorScheme == .dark ? 0.1 : 0.3),
                                            Color.white.opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(colorScheme == .dark ? 0.3 : 0.5),
                                            Color.white.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
                .shadow(color: .black.opacity(0.15), radius: 40, x: 0, y: 20)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                .scaleEffect(isAnimatingIn ? 1.0 : 0.85)
                .opacity(isAnimatingIn ? 1.0 : 0.0)
                .onDrop(
                    of: [.text],
                    delegate: FolderRemoveDropDelegate(
                        folder: Binding(get: { folder! }, set: { folder = $0 }),
                        draggedApp: $draggedApp,
                        onRemoveApp: addAppToPage
                    )
                )
                .onAppear {
                    performEntranceAnimation()
                }
            }
        }
    }
    
    private func performEntranceAnimation() {
        withAnimation(.interpolatingSpring(stiffness: 280, damping: 22)) {
            isAnimatingIn = true
        }
        
        withAnimation(.easeOut(duration: 0.3)) {
            contentOpacity = 1.0
        }
        
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 25)) {
            headerOffset = 0
        }
    }
    
    private func dismissWithAnimation() {
        withAnimation(.easeIn(duration: 0.1)) {
            contentOpacity = 0
            headerOffset = -20
            isAnimatingIn = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            saveFolder()
        }
    }
    
    private func saveFolder() {
        guard let pageIndex = pages.firstIndex(where: { page in page.contains(where: { $0.id == folder!.id }) }),
              let itemIndex = pages[pageIndex].firstIndex(where: { $0.id == folder!.id }) else {
            return
        }
        let newFolder = Folder(name: folder!.name, page: folder!.page, apps: folder!.apps)
        pages[pageIndex][itemIndex] = .folder(newFolder)
        folder = nil
    }
    
    private func addAppToPage(app: AppInfo) {
        guard let folder = folder,
              let pageIndex = pages.firstIndex(where: { page in page.contains(where: { $0.id == folder.id }) }) else { return }
        let updatedApp = AppInfo(name: app.name, icon: app.icon, path: app.path, page: pageIndex)
        pages[pageIndex].append(.app(updatedApp))
        handlePageOverflow(pageIndex: pageIndex)
    }
    
    private func handlePageOverflow(pageIndex: Int) {
        while pages[pageIndex].count > settings.appsPerPage {
            let overflowItem = pages[pageIndex].removeLast()
            let nextPage = pageIndex + 1
            let updatedOverflowItem: AppGridItem
            switch overflowItem {
            case .app(let app):
                updatedOverflowItem = .app(AppInfo(name: app.name, icon: app.icon, path: app.path, page: nextPage))
            case .folder(let folder):
                updatedOverflowItem = .folder(Folder(name: folder.name, page: nextPage, apps: folder.apps))
            }
            if nextPage >= pages.count {
                pages.append([updatedOverflowItem])
            } else {
                pages[nextPage].insert(updatedOverflowItem, at: 0)
                handlePageOverflow(pageIndex: nextPage)
            }
        }
    }
}
