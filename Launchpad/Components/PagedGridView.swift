import AppKit
import SwiftUI

struct PagedGridView: View {
  let scrollDebounceInterval: TimeInterval = 0.8
  let scrollActivationThreshold: CGFloat = 80

  @Binding var pages: [[AppGridItem]]
  var settings: LaunchpadSettings
    
  @GestureState private var dragOffset: CGFloat = 0
  @State private var currentPage = 0
  @State private var draggedPage = 0
  @State private var lastScrollTime = Date.distantPast
  @State private var accumulatedScrollX: CGFloat = 0
  @State private var eventMonitor: Any?
  @State private var searchText = ""
  @State private var isFolderOpen = false
  @State private var draggedItem: AppGridItem?
  @State private var selectedFolder: Folder?
  @Environment(\.colorScheme) private var colorScheme

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
                  isFolderOpen: isFolderOpen,

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
          isFolderOpen: isFolderOpen,
          searchText: searchText
        )
      }
      .overlay {
        if isFolderOpen {
          FolderOverlayView(
            pages: $pages,
            selectedFolder: $selectedFolder,
            isFolderOpen: $isFolderOpen,
            settings: settings
          )
        } else {
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
    .onChange(of: isFolderOpen) { oldValue, newValue in
      if newValue && !isFolderOpen {
        withAnimation(.easeInOut(duration: 0.4)) {
          isFolderOpen = true
        }
      }
    }
  }

  private func handleItemTap(_ item: AppGridItem) {
    switch item {
    case .app(_):
      return
    case .folder(let folder):
      selectedFolder = folder
      isFolderOpen = true
      withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {
        isFolderOpen = true
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
    if !searchText.isEmpty || isFolderOpen {
      return event
    }

    let absX = abs(event.scrollingDeltaX)
    let absY = abs(event.scrollingDeltaY)
    guard absX > absY, absX > 0 else { return event }

    let now = Date()
    if now.timeIntervalSince(lastScrollTime) < scrollDebounceInterval { return event }

    accumulatedScrollX += event.scrollingDeltaX

    if accumulatedScrollX <= -scrollActivationThreshold {
      currentPage = min(currentPage + 1, pages.count - 1)
      resetScrollState(at: now)
      return nil
    } else if accumulatedScrollX >= scrollActivationThreshold {
      currentPage = max(currentPage - 1, 0)
      resetScrollState(at: now)
      return nil
    }

    return event
  }

  private func handleKeyEvent(_ event: NSEvent) -> NSEvent? {
    if (!searchText.isEmpty && (event.keyCode == 123 || event.keyCode == 124)) || isFolderOpen {
      return event
    }

    switch event.keyCode {
    case 53:  // ESC key
      AppLauncher.exit()
      return nil
    case 123:  // Left arrow key
      if currentPage > 0 {
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 100)) {
          currentPage = currentPage - 1
        }
        return nil
      }
    case 124:  // Right arrow key
      if currentPage < pages.count - 1 {
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 100)) {
          currentPage = currentPage + 1
        }
        return nil
      }
    default:
      break
    }
    return event
  }

  private func resetScrollState(at time: Date) {
    lastScrollTime = time
    accumulatedScrollX = 0
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
