import SwiftUI

struct InlineResponseView: View {
    @Bindable var viewModel: ResponseViewModel
    let closeAction: () -> Void

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView { 
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(viewModel.messages) { 
                            message in MessageBlock(message: message, fontSize: viewModel.fontSize, hideCopyButton: true).id(message.id)
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
                .onChange(of: viewModel.messages) { old, new in
                    guard new.count > old.count else { return }
                    if reduceMotion {
                        proxy.scrollTo("bottom")
                    } else {
                        withAnimation(.easeOut(duration: 0.25)) {
                            proxy.scrollTo("bottom")
                        }
                    }
                }
                .onChange(of: viewModel.messages.last?.content) { _, _ in 
                    guard viewModel.messages.last?.isStreaming == true else { return }
                    proxy.scrollTo("bottom")
                }
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