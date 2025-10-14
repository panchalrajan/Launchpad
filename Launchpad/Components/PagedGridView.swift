import AppKit
import SwiftUI

struct PagedGridView: View {
   @Binding var pages: [[AppGridItem]]
   var settings: LaunchpadSettings
   var showSettings: () -> Void
   
   @State private var currentPage = 0
   @State private var lastScrollTime = Date.distantPast
   @State private var accumulatedScrollX: CGFloat = 0
   @State private var eventMonitor: Any?
   @State private var searchText = ""
   @State private var draggedItem: AppGridItem?
   @State private var selectedFolder: Folder?
   
   var body: some View {
      VStack(spacing: 0) {
         SearchBarView(
            searchText: searchText,
            transparency: settings.transparency
         )
         GeometryReader { geo in
            if searchText.isEmpty {
               HStack(spacing: 0) {
                  ForEach(pages.indices, id: \.self) { pageIndex in
                     SinglePageView(
                        pages: $pages,
                        draggedItem: $draggedItem,
                        pageIndex: pageIndex,
                        settings: settings,
                        isFolderOpen: selectedFolder != nil,
                        onItemTap: handleTap
                     )
                     .frame(width: geo.size.width, height: geo.size.height)
                  }
               }
               .offset(x: -CGFloat(currentPage) * geo.size.width)
               .animation(LaunchPadConstants.springAnimation, value: currentPage)
            } else {
               SearchResultsView(
                  apps: filteredApps(),
                  settings: settings,
                  onItemTap: handleTap
               )
               .frame(width: geo.size.width, height: geo.size.height)
            }
         }
         PageIndicatorView(
            currentPage: $currentPage,
            pageCount: pages.count,
            isFolderOpen: selectedFolder != nil,
            searchText: searchText,
            settings: settings
         )
      }
      .onAppear(perform: setupEventMonitoring)
      .onDisappear(perform: cleanupEventMonitoring)
      
      FolderDetailView(
         pages: $pages,
         folder: $selectedFolder,
         settings: settings,
         onItemTap: handleTap
      )
      
      PageDropZonesView(
         currentPage: currentPage,
         totalPages: pages.count,
         draggedItem: draggedItem,
         onNavigateLeft: navigateToPreviousPage,
         onNavigateRight: navigateToNextPage,
         transparency: settings.transparency
      )
   }
   
   private func filteredApps() -> [AppInfo] {
      guard !searchText.isEmpty else { return [] }
      
      let searchTerm = searchText.lowercased()
      return pages.flatMap { $0 }.flatMap { item -> [AppInfo] in
         switch item {
         case .app(let app):
            return app.name.lowercased().contains(searchTerm) ? [app] : []
         case .folder(let folder):
            if folder.name.lowercased().contains(searchTerm) {
               return folder.apps
            } else {
               return folder.apps.filter { $0.name.lowercased().contains(searchTerm) }
            }
         }
      }
   }
   
   private func handleTap(item: AppGridItem) {
      switch item {
      case .app(let app):
         AppLauncher.launch(path: app.path)
      case .folder(let folder):
         selectedFolder = folder
      }
   }
   
   private func setupEventMonitoring() {
      eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.scrollWheel, .keyDown]) { event in
         switch event.type {
         case .scrollWheel:
            return handleScrollEvent(event: event)
         case .keyDown:
            return handleKeyEvent(event: event)
         default:
            return event
         }
      }
      
      NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: .main) { notification in
         guard let activatedApp = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else { return }
         
         let isSelf = activatedApp.bundleIdentifier == Bundle.main.bundleIdentifier
         Task { @MainActor in
            if (isSelf) {
               print("Entering Launchpad.")
               handleAppActivation();
            } else {
               print("Exiting Launchpad.")
               AppLauncher.exit()
            }
         }
      }
   }
   
   private func cleanupEventMonitoring() {
      if let monitor = eventMonitor {
         NSEvent.removeMonitor(monitor)
         eventMonitor = nil
      }
   }
   
   private func handleScrollEvent(event: NSEvent) -> NSEvent? {
      guard searchText.isEmpty && selectedFolder == nil else { return event }
      
      let absX = abs(event.scrollingDeltaX)
      let absY = abs(event.scrollingDeltaY)
      guard absX > absY && absX > 0 else { return event }
      
      let now = Date()
      guard now.timeIntervalSince(lastScrollTime) >= settings.scrollDebounceInterval else { return event }
      
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
   
   private func handleKeyEvent(event: NSEvent) -> NSEvent? {
      print(event.keyCode)
      // Handle regular character input
      if let characters = event.characters, !characters.isEmpty {
         let char = characters.first!
         if char.isLetter || char.isNumber || char.isWhitespace {
            if(char.isNewline)
            {
               launchFirstSearchResult();
            }
            else
            {
               searchText += characters
            }
            return event
         }
      }
      
      switch event.keyCode {
      case 53:  // ESC key
         AppLauncher.exit()
      case 123:  // Left arrow key
         navigateToPreviousPage()
      case 124:  // Right arrow key
         navigateToNextPage()
      case 43:  // Comma key
         showSettings()
      case 51:  // Backspace key
         searchText = String(searchText.dropLast())
      default:
         break
      }
      return event
   }
   
   private func navigateToPreviousPage() {
      guard currentPage > 0 else { return }
      
      withAnimation(LaunchPadConstants.springAnimation) {
         currentPage = currentPage - 1
      }
   }
   
   private func navigateToNextPage() {
      if currentPage < pages.count - 1 {
         withAnimation(LaunchPadConstants.springAnimation) {
            currentPage += 1
         }
      } else {
         createNewPage()
      }
   }
   
   private func createNewPage() {
      pages.append([])
      withAnimation(LaunchPadConstants.springAnimation) {
         currentPage = pages.count - 1
      }
   }
   
   private func launchFirstSearchResult() {
      guard !searchText.isEmpty else { return }
      guard let firstApp = filteredApps().first else { return }
      
      AppLauncher.launch(path: firstApp.path)
   }
   
   private func handleAppActivation() {
      currentPage = 0;
      searchText = ""
   }
}
