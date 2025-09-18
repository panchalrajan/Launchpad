import SwiftUI
import AppKit

struct PagedGridView: View {
    @Binding var pages: [[AppInfo]]
    let columns = 7
    let rows = 5
    
    @State private var currentPage = 0
    @GestureState private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var lastScrollTime = Date.distantPast
    @State private var accumulatedScrollX: CGFloat = 0
    @State private var eventMonitor: Any?
    @State private var searchText = ""
    
    private let scrollDebounceInterval: TimeInterval = 0.8
    private let scrollActivationThreshold: CGFloat = 80

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
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .frame(width: 480, height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .fill(Color(NSColor.windowBackgroundColor).opacity(0.6))
                        )
                        .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 3)
                    Spacer()
                }
                .padding(.top, 40)
                .padding(.bottom, 20)

                if searchText.isEmpty {
                    GeometryReader { geo in
                        HStack(spacing: 0) {
                            ForEach(0..<pages.count, id: \.self) { pageIndex in
                                AppGridView(apps: $pages[pageIndex], columns: columns)
                                    .frame(width: geo.size.width, height: geo.size.height)
                            }
                        }.onTapGesture {
                            NSApp.terminate(nil)
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
                    }



                } else {
                    GeometryReader { geo in
                        SearchResultsView(apps: filteredApps(), columns: columns)
                            .frame(width: geo.size.width, height: geo.size.height)
                    }
                }
                
                HStack(spacing: 12) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.white : Color.gray.opacity(0.5))
                            .frame(width: 10, height: 10)
                            .scaleEffect(index == currentPage ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: currentPage)
                            .onTapGesture {
                                withAnimation(.interpolatingSpring(stiffness: 300, damping: 100)) {
                                    currentPage = index
                                }
                            }
                    }
                }
                .padding(.top, 15)
                .padding(.bottom, 90)
                .opacity(searchText.isEmpty ? 1 : 0)
            }
        }
    }

    func filteredApps() -> [AppInfo] {
        pages.flatMap { $0 }.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
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
        if !searchText.isEmpty {
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
        if !searchText.isEmpty && (event.keyCode == 123 || event.keyCode == 124) {
            return event
        }
        
        switch event.keyCode {
        case 53: // ESC key
            NSApp.terminate(nil)
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
