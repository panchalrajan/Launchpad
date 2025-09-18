import SwiftUI
import AppKit

struct PagedGridView: View {
    let scrollDebounceInterval: TimeInterval = 0.8
    let scrollActivationThreshold: CGFloat = 80
    
    @Binding var pages: [[AppGridItem]]
    var columns: Int
    var rows: Int
    var iconSize: Double
    var dropDelay: Double
    @GestureState private var dragOffset: CGFloat = 0
    @State private var currentPage = 0
    @State private var isDragging = false
    @State private var lastScrollTime = Date.distantPast
    @State private var accumulatedScrollX: CGFloat = 0
    @State private var eventMonitor: Any?
    @State private var searchText = ""
    @State private var isFolderOpen = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            Color.clear
                .background(VisualEffectView(material: .fullScreenUI, blendingMode: .behindWindow))
                .ignoresSafeArea()
                .contentShape(Rectangle())
            VStack(spacing: 0) {
                HStack {             
                    Spacer()
                    SearchField(text: $searchText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .frame(width: 480, height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color(NSColor.windowBackgroundColor).opacity(0.4))
                        )
                        .shadow(
                            color: colorScheme == .dark 
                            ? Color.black.opacity(0.2) 
                            : Color.black.opacity(0.1), 
                            radius: 10, x: 0, y: 3
                        )
                    Spacer()
                }
                .padding(.top, 40)
                .padding(.bottom, 24)
                
                GeometryReader { geo in
                    if searchText.isEmpty {
                        
                        HStack(spacing: 0) {
                            ForEach(0..<pages.count, id: \.self) { pageIndex in
                                AppGridView(items: $pages[pageIndex], columns: columns, iconSize: iconSize, dropDelay: dropDelay, isFolderOpen: $isFolderOpen)
                                    .frame(width: geo.size.width, height: geo.size.height)
                            }
                        }.onTapGesture {
                            AppLauncher.shared.exit()
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
                        SearchResultsView(apps: filteredApps(), columns: columns, iconSize: iconSize)
                            .frame(width: geo.size.width, height: geo.size.height)
                    }
                }
                
                HStack(spacing: 16) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage 
                                  ? (colorScheme == .dark ? Color.white : Color.primary)
                                  : (colorScheme == .dark ? Color.gray.opacity(0.4) : Color.gray.opacity(0.6))
                            )
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentPage ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: currentPage)
                            .onTapGesture {
                                if !isFolderOpen {
                                    withAnimation(.interpolatingSpring(stiffness: 300, damping: 100)) {
                                        currentPage = index
                                    }
                                }
                            }
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 120)
                .opacity(searchText.isEmpty && !isFolderOpen ? 1 : 0)
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
                // Search folder name
                if folder.name.lowercased().contains(searchText.lowercased()) {
                    matchingApps.append(contentsOf: folder.apps)
                } else {
                    // Search apps within folder
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
        case 53: // ESC key
            AppLauncher.shared.exit()
            return nil
        case 123: // Left arrow key
            if currentPage > 0 {
                withAnimation(.interpolatingSpring(stiffness: 300, damping: 100)) {
                    currentPage = currentPage - 1
                }
                return nil
            }
        case 124: // Right arrow key
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
}
