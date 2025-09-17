import SwiftUI
import AppKit

struct PagedGridView: View {
    let pages: [[AppInfo]]
    let columns = 7
    let rows = 5
    @State private var currentPage = 0
    @GestureState private var dragOffset: CGFloat = 0
    @State private var isDragging = false

    // Scroll wheel handling
    @State private var lastScrollTime = Date.distantPast
    let scrollDebounceInterval: TimeInterval = 0.8
    @State private var accumulatedScrollX: CGFloat = 0
    let scrollActivationThreshold: CGFloat = 80
    @State private var eventMonitor: Any?

    @State private var searchText = ""

    var body: some View {
        ZStack {
            Color.clear
                .background(VisualEffectView(material: .fullScreenUI, blendingMode: .behindWindow))
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    NSApp.terminate(nil)
                }

            VStack(spacing: 0) {
                // 🔍 Search bar
                HStack {
                    Spacer()
                    AutoFocusSearchField(text: $searchText)
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
                                ContentView(apps: pages[pageIndex], columns: columns)
                                    .frame(width: geo.size.width, height: geo.size.height)
                            }
                        }.onTapGesture {
                            NSApp.terminate(nil)
                        }
                        .offset(x: -CGFloat(currentPage) * geo.size.width)
                        .offset(x: dragOffset)
                        .animation(.interpolatingSpring(stiffness: 300, damping: 100), value: currentPage)
                        .onAppear {
                            // Monitor scroll wheel only when not dragging, and only horizontal intent
                            eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { event in
                                // Prefer horizontal paging only when horizontal dominates
                                let absX = abs(event.scrollingDeltaX)
                                let absY = abs(event.scrollingDeltaY)
                                guard absX > absY, absX > 0 else {
                                    return event
                                }

                                // Debounce by time to limit to one page per gesture burst
                                let now = Date()
                                if now.timeIntervalSince(lastScrollTime) < scrollDebounceInterval {
                                    return event
                                }

                                // Accumulate horizontal delta; require a threshold
                                accumulatedScrollX += event.scrollingDeltaX

                                if accumulatedScrollX <= -scrollActivationThreshold {
                                    currentPage = min(currentPage + 1, pages.count-1)
                                    lastScrollTime = now
                                    accumulatedScrollX = 0
                                    return nil
                                } else if accumulatedScrollX >= scrollActivationThreshold {
                                    currentPage = max(currentPage - 1, 0)
                                    lastScrollTime = now
                                    accumulatedScrollX = 0
                                    return nil
                                }

                                return event
                            }

                            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                                if event.keyCode == 53 { // ESC
                                    NSApp.terminate(nil)
                                    return nil
                                }
                                return event
                            }
                        }
                        .onDisappear {
                            if let monitor = eventMonitor {
                                NSEvent.removeMonitor(monitor)
                                eventMonitor = nil
                            }
                        }
                    }

                    // 🔘 Page indicator dots
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.white : Color.gray.opacity(0.5))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.top, 15)
                    .padding(.bottom, 90)

                } else {
                    // 🔍 Search results — disable scrolling and hide scrollbars
                    GeometryReader { geo in
                        ScrollView(.vertical, showsIndicators: false) {
                                ContentView(apps: filteredApps(), columns: columns)
                                    .frame(width: geo.size.width, height: geo.size.height)
                        }.onTapGesture {
                            NSApp.terminate(nil)
                        }
                    }
                }
            }
        }
    }

    func filteredApps() -> [AppInfo] {
        pages.flatMap { $0 }.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
    }
}
