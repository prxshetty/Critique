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