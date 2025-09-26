import AppKit
import SwiftUI

struct PagedGridView: View {
   @Binding var pages: [[AppGridItem]]
   var settings: LaunchpadSettings

   @GestureState private var dragOffset: CGFloat = 0
   @State private var currentPage = 0
   @State private var draggedPage = 0
   @State private var lastScrollTime = Date.distantPast
   @State private var accumulatedScrollX: CGFloat = 0
   @State private var eventMonitor: Any?
   @State private var searchText = ""
   @State private var draggedItem: AppGridItem?
   @State private var selectedFolder: Folder?

   var body: some View {
      ZStack {
         Color.clear
            .background(VisualEffectView(material: .fullScreenUI, blendingMode: .behindWindow))
            .ignoresSafeArea()
            .contentShape(Rectangle())
         VStack(spacing: 0) {
            SearchBarView(searchText: $searchText)
            GeometryReader { geo in
               if searchText.isEmpty {
                  HStack(spacing: 0) {
                     ForEach(0..<pages.count, id: \.self) { pageIndex in
                        SinglePageView(
                           pages: $pages,
                           draggedItem: $draggedItem,
                           pageIndex: pageIndex,
                           settings: settings,
                           isFolderOpen: selectedFolder != nil,
                           onItemTap: handleItemTap
                        )
                        .frame(width: geo.size.width, height: geo.size.height)
                     }
                  }
                  .offset(x: -CGFloat(currentPage) * geo.size.width)
                  .offset(x: dragOffset)
                  .animation(.interpolatingSpring(stiffness: 300, damping: 100), value: currentPage)
                  .onAppear {
                     setupEventMonitoring()
                  }
                  .onDisappear {
                     cleanupEventMonitoring()
                  }
               } else {
                  SearchResultsView(apps: filteredApps(), settings: settings)
                     .frame(width: geo.size.width, height: geo.size.height)
               }
            }

            PageIndicatorView(
               currentPage: $currentPage,
               pageCount: pages.count,
               isFolderOpen: selectedFolder != nil,
               searchText: searchText
            )
         }
         .overlay {

               FolderOverlayView(
                  pages: $pages,
                  folder: $selectedFolder,
                  settings: settings,
               )

               PageDropZonesView(
                  currentPage: currentPage,
                  totalPages: pages.count,
                  draggedItem: draggedItem,
                  onNavigateLeft: navigateToPreviousPage,
                  onNavigateRight: navigateToNextPage
               )
            }
         }
   }

   private func handleItemTap(_ item: AppGridItem) {
      switch item {
      case .app(let app):
         AppLauncher.launch(path: app.path)
      case .folder(let folder):
         selectedFolder = folder
         withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {

         }
      }
   }

   func filteredApps() -> [AppInfo] {
      let allItems = pages.flatMap { $0 }
      var matchingApps: [AppInfo] = []

      for item in allItems {
         switch item {
         case .app(let app):
            if app.name.lowercased().contains(searchText.lowercased()) {
               matchingApps.append(app)
            }
         case .folder(let folder):
            if folder.name.lowercased().contains(searchText.lowercased()) {
               matchingApps.append(contentsOf: folder.apps)
            } else {
               let matchingFolderApps = folder.apps.filter {
                  $0.name.lowercased().contains(searchText.lowercased())
               }
               matchingApps.append(contentsOf: matchingFolderApps)
            }
         }
      }

      return matchingApps
   }

   private func setupEventMonitoring() {
      eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.scrollWheel, .keyDown]) { event in
         switch event.type {
         case .scrollWheel:
            return handleScrollEvent(event)
         case .keyDown:
            return handleKeyEvent(event)
         default:
            return event
         }
      }
   }

   private func cleanupEventMonitoring() {
      if let monitor = eventMonitor {
         NSEvent.removeMonitor(monitor)
         eventMonitor = nil
      }
   }

   private func handleScrollEvent(_ event: NSEvent) -> NSEvent? {
      if !searchText.isEmpty || selectedFolder != nil {
         return event
      }

      let absX = abs(event.scrollingDeltaX)
      let absY = abs(event.scrollingDeltaY)
      guard absX > absY, absX > 0 else { return event }

      let now = Date()
      if now.timeIntervalSince(lastScrollTime) < settings.scrollDebounceInterval { return event }

      accumulatedScrollX += event.scrollingDeltaX

      if accumulatedScrollX <= -settings.scrollActivationThreshold {
         currentPage = min(currentPage + 1, pages.count - 1)
         resetScrollState(at: now)
         return nil
      } else if accumulatedScrollX >= settings.scrollActivationThreshold {
         currentPage = max(currentPage - 1, 0)
         resetScrollState(at: now)
         return nil
      }

      return event
   }

   private func resetScrollState(at time: Date) {
      lastScrollTime = time
      accumulatedScrollX = 0
   }

   private func handleKeyEvent(_ event: NSEvent) -> NSEvent? {
      switch event.keyCode {
      case 53:  // ESC key
         AppLauncher.exit()
      case 123:  // Left arrow key
         navigateToPreviousPage()
      case 124:  // Right arrow key
         navigateToNextPage()
      default:
         break
      }
      return event
   }

   private func navigateToPreviousPage() {
      guard currentPage > 0 else { return }

      withAnimation(.interpolatingSpring(stiffness: 300, damping: 100)) {
         currentPage = currentPage - 1
      }
   }

   private func navigateToNextPage() {
      guard currentPage < pages.count - 1 else { return }

      withAnimation(.interpolatingSpring(stiffness: 300, damping: 100)) {
         currentPage = currentPage + 1
      }
   }
}
