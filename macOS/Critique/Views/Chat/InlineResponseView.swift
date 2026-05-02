import SwiftUI

struct InlineResponseView: View {
    @Bindable var viewModel: ResponseViewModel
    @Bindable var popupViewModel: PopupViewModel
    let closeAction: () -> Void

    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.colorScheme) var colorScheme



    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                VStack(spacing: 0) {
                    ScrollView { 
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(viewModel.messages) { message in
                                MessageBlock(message: message, fontSize: viewModel.fontSize, hideCopyButton: true)
                                    .id(message.id)
                            }
                            
                            if viewModel.isProcessing && viewModel.messages.last?.isStreaming == true && viewModel.messages.last?.content.isEmpty == true {
                                ThinkingIndicator()
                                    .padding(.top, 4)
                            }

                            Color.clear.frame(height: 1).id("bottom")
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                    .background(InjectedScrollHider())
                    
                    if !viewModel.isProcessing || AppSettings.shared.useMultiIteration {
                        if AppSettings.shared.useMultiIteration || popupViewModel.isResponseExpanded {
                            bottomToolbar
                                .padding(.horizontal, 16)
                                .padding(.vertical, 4)
                        }
                    }
                }
                .onChange(of: viewModel.messages) { old, new in
                    guard new.count > old.count else { return }
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: viewModel.messages.last?.content) { _, _ in 
                    guard viewModel.messages.last?.isStreaming == true else { return }
                    scrollToBottom(proxy: proxy)
                }
            }
        }
    }

    private var iterationIndicator: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                let isSelected = index == viewModel.selectedIterationIndex
                let isGenerated = index < viewModel.iterations.count
                Circle()
                    .fill(isSelected ? Color.blue : (isGenerated ? Color.secondary : Color.secondary.opacity(0.3)))
                    .frame(width: 6, height: 6)
            }
        }
    }

    private var bottomToolbar: some View {
        HStack {
            Spacer()
            if AppSettings.shared.useMultiIteration {
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        let isSelected = index == viewModel.selectedIterationIndex
                        let isGenerated = index < viewModel.iterations.count
                        
                        Circle()
                            .fill(isSelected ? Color.blue : Color.secondary.opacity(isGenerated ? 1.0 : 0.3))
                            .frame(width: 7, height: 7)
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