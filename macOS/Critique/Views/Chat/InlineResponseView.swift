import SwiftUI

struct InlineResponseView: View {
    @Bindable var viewModel: ResponseViewModel
    let closeAction: () -> Void

    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.colorScheme) var colorScheme
    @Bindable private var settings = AppSettings.shared
    
    private var themeTokens: DesignSystem.ThemeTokens {
        DesignSystem.tokens(for: settings.themeStyle)
    }
    
    @State private var contentHeight: CGFloat = .zero

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView { 
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(viewModel.messages) { message in
                            MessageBlock(message: message, fontSize: viewModel.fontSize, hideCopyButton: true, useSimpleRenderer: true)
                                .id(message.id)
                        }
                        
                        if viewModel.isProcessing && viewModel.messages.last?.isStreaming == true && viewModel.messages.last?.content.isEmpty == true {
                            ThinkingIndicator()
                                .padding(.top, 4)
                        }

                        Color.clear.frame(height: 1).id("bottom")
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 25)
                    .padding(.bottom, 14)
                    .background(
                        GeometryReader { geo in
                            Color.clear.preference(key: InlineContentHeightKey.self, value: geo.size.height)
                        }
                    )
                }
                .frame(height: contentHeight > 0 ? min(contentHeight, 300) : nil)
                .animation(.easeInOut(duration: 0.25), value: contentHeight)
                .onPreferenceChange(InlineContentHeightKey.self) { height in
                    if height != self.contentHeight {
                        self.contentHeight = height
                        let scrollHeight = min(height, 300)
                        let headerHeight: CGFloat = AppSettings.shared.useMultiIteration ? 22 : 0
                        AppState.shared.toolbarViewModel.inlineResponseHeight = scrollHeight + headerHeight
                    }
                }
                .background(InjectedScrollHider())
                .onChange(of: viewModel.messages) { old, new in
                    guard new.count > old.count else { return }
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: viewModel.messages.last?.content) { _, _ in 
                    // For the initial response, we want to show the top so the user can read from the start.
                    // For follow-up chats or active streaming, we scroll to show progress.
                    if viewModel.messages.count > 1 || viewModel.messages.last?.isStreaming == true {
                        scrollToBottom(proxy: proxy)
                    }
                }
                // Safety net: if Apple Intelligence resolved before SwiftUI finished
                // mounting this view (the fast-provider race), scroll to show content.
                .onAppear {
                    DispatchQueue.main.async {
                        // Only auto-scroll to bottom on appear if we're already in a follow-up conversation
                        if viewModel.messages.count > 1 {
                            scrollToBottom(proxy: proxy)
                        }
                    }
                }
            }
            
            if AppSettings.shared.useMultiIteration {
                iterationHeader
                    .padding(.top, 4)
                    .padding(.bottom, 12)
            }
        }
        .windowBackground(shape: AnyShape(RoundedRectangle(cornerRadius: 16)))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(themeTokens.borderColor(colorScheme), lineWidth: 1.0)
        )
    }

    private var iterationHeader: some View {
        HStack {
            Spacer()
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    let isSelected = index == viewModel.selectedIterationIndex
                    let isGenerated = index < viewModel.iterations.count
                    
                    Circle()
                        .fill(isSelected ? Color.blue : Color.secondary.opacity(isGenerated ? 1.0 : 0.3))
                        .frame(width: 6, height: 6)
                        .shimmer(isActive: !isGenerated && viewModel.isProcessing)
                        .onTapGesture {
                            if isGenerated {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    viewModel.selectedIterationIndex = index
                                    updateMessageFromIteration()
                                }
                            }
                        }
                }
            }
            Spacer()
        }
        .buttonStyle(.plain)
    }

    private func updateMessageFromIteration() {
        viewModel.selectIteration(index: viewModel.selectedIterationIndex)
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        if reduceMotion {
            proxy.scrollTo("bottom")
        } else {
            withAnimation(.easeOut(duration: 0.25)) {
                proxy.scrollTo("bottom")
            }
        }
    }
}

/// A utility that injects into the background of a ScrollView to find the 
/// parent NSScrollView and hide its scrollbars at the AppKit level.
struct InjectedScrollHider: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        return ScrollHiderView()
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    private class ScrollHiderView: NSView {
        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            hideScrollers()
        }

        private func hideScrollers() {
            var current: NSView? = self
            while let v = current {
                if let scrollView = v as? NSScrollView {
                    scrollView.hasVerticalScroller = false
                    scrollView.hasHorizontalScroller = false
                    scrollView.verticalScroller?.alphaValue = 0
                    scrollView.horizontalScroller?.alphaValue = 0
                    // Sometimes SwiftUI re-enables them, so we try multiple times
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        scrollView.hasVerticalScroller = false
                        scrollView.hasHorizontalScroller = false
                    }
                }
                current = v.superview
            }
        }
    }
}

private struct InlineContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        let next = nextValue()
        value = next > value ? next : value
    }
}