import SwiftUI
import MarkdownView
import Observation

// MARK: - String Extension for Markdown Processing

extension String {
    fileprivate func strippingOuterCodeBlock() -> String {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        let pattern = #"^```(?:markdown|md)\s*\n([\s\S]*?)\n```$"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]),
              let match = regex.firstMatch(in: trimmed, options: [], range: NSRange(trimmed.startIndex..., in: trimmed)),
              let contentRange = Range(match.range(at: 1), in: trimmed) else {
            return self
        }
        return String(trimmed[contentRange])
    }

    fileprivate func normalizedForMarkdown() -> String {
        return self.strippingOuterCodeBlock()
    }
}

// MARK: - Chat Message Model

struct ChatMessage: Identifiable, Equatable, Sendable {
    let id: UUID
    let role: String
    var content: String
    let timestamp: Date
    var isStreaming: Bool

    init(role: String, content: String, isStreaming: Bool = false) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = Date()
        self.isStreaming = isStreaming
    }

    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id &&
        lhs.role == rhs.role &&
        lhs.content == rhs.content &&
        lhs.timestamp == rhs.timestamp &&
        lhs.isStreaming == rhs.isStreaming
    }
}

// MARK: - Response View

struct ResponseView: View {
    @State private var viewModel: ResponseViewModel
    @Bindable private var settings = AppSettings.shared
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var inputText: String = ""
    @State private var isRegenerating: Bool = false
    @State private var errorMessage: String?
    @State private var showError: Bool = false
    @State private var copyPulse: Bool = false

    init(
        content: String,
        selectedText: String,
        option: WritingOption? = nil,
        provider: any AIProvider,
        continuationSystemPrompt: String? = nil
    ) {
        self._viewModel = State(initialValue: ResponseViewModel(
            content: content,
            selectedText: selectedText,
            option: option,
            provider: provider,
            continuationSystemPrompt: continuationSystemPrompt
        ))
    }

    init(
        selectedText: String,
        option: WritingOption? = nil,
        provider: any AIProvider,
        systemPrompt: String,
        userPrompt: String,
        images: [Data],
        continuationSystemPrompt: String? = nil
    ) {
        self._viewModel = State(initialValue: ResponseViewModel(
            selectedText: selectedText,
            option: option,
            provider: provider,
            systemPrompt: systemPrompt,
            userPrompt: userPrompt,
            images: images,
            continuationSystemPrompt: continuationSystemPrompt
        ))
    }

    var body: some View {
        VStack(spacing: 0) {

            // ── Top action bar ──────────────────────────────────────────
            HStack(spacing: 6) {
                // Copy button — the primary action
                Button {
                    viewModel.copyContent()
                    withAnimation(.spring(response: 0.3)) { copyPulse = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation { copyPulse = false }
                    }
                } label: {
                    Label(
                        viewModel.showCopyConfirmation ? "Copied" : "Copy",
                        systemImage: viewModel.showCopyConfirmation ? "checkmark" : "doc.on.doc"
                    )
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(viewModel.showCopyConfirmation ? Color.green : Color.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(Color.primary.opacity(viewModel.showCopyConfirmation ? 0.0 : 0.07))
                    )
                }
                .buttonStyle(.plain)
                .animation(.easeInOut(duration: 0.2), value: viewModel.showCopyConfirmation)

                Spacer()

                // Processing indicator
                if viewModel.isProcessing {
                    HStack(spacing: 5) {
                        ProgressView()
                            .controlSize(.small)
                            .scaleEffect(0.7)
                        Text("Writing…")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundStyle(.tertiary)
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                } else if settings.useMultiIteration && viewModel.iterations.count > 0 {
                    // Iteration Switcher for ResponseView
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
                                            viewModel.selectIteration(index: index)
                                        }
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 10)
                }

                // Font size controls — compact and unobtrusive
                HStack(spacing: 2) {
                    fontSizeButton(icon: "textformat.size.smaller", action: { viewModel.fontSize -= 1 },
                                   disabled: viewModel.fontSize <= 10)
                    fontSizeButton(icon: "textformat.size.larger", action: { viewModel.fontSize += 1 },
                                   disabled: viewModel.fontSize >= 22)
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .animation(.easeInOut(duration: 0.2), value: viewModel.isProcessing)

            Divider().opacity(0.5)

            // ── Content area ────────────────────────────────────────────
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(viewModel.messages) { message in
                            MessageBlock(message: message, fontSize: viewModel.fontSize)
                                .id(message.id)
                        }

                        // Thinking state when no streaming content yet
                        if viewModel.isProcessing && viewModel.messages.last?.isStreaming == true &&
                           viewModel.messages.last?.content.isEmpty == true {
                            ThinkingIndicator()
                                .padding(.top, 4)
                        }

                        // Scroll anchor
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

            Divider().opacity(0.5)

            // ── Follow-up input ─────────────────────────────────────────
            FollowUpInputBar(
                text: $inputText,
                isDisabled: viewModel.isProcessing,
                isLoading: isRegenerating,
                onSubmit: sendMessage
            )
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .windowBackground(shape: Rectangle())
        .alert("Error", isPresented: $showError, presenting: errorMessage) { _ in
            Button("OK") { errorMessage = nil }
        } message: { message in
            Text(message)
        }
        .onDisappear {
            viewModel.cancelOngoingTasks()
        }
    }

    @ViewBuilder
    private func fontSizeButton(icon: String, action: @escaping () -> Void, disabled: Bool) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(disabled ? AnyShapeStyle(.tertiary) : AnyShapeStyle(.secondary))
                .frame(width: 26, height: 26)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }

    private func sendMessage() {
        guard !inputText.isEmpty, !viewModel.isProcessing else { return }
        let question = inputText
        inputText = ""
        isRegenerating = true
        viewModel.startFollowUpQuestion(
            question,
            onCompletion: { isRegenerating = false },
            onFailure: { message in
                errorMessage = message
                showError = true
            }
        )
    }
}

// MARK: - Message Block

/// Replaces chat bubbles. Assistant output fills full width. User follow-ups
/// appear as small labeled prompts to keep focus on the AI content.
struct MessageBlock: View {
    let message: ChatMessage
    let fontSize: CGFloat
    var hideCopyButton: Bool = false
    /// When true, renders assistant text with native SwiftUI Text() instead of the
    /// WKWebView-backed MarkdownView. Use this for compact/inline contexts to avoid
    /// the intermittent blank-text bug caused by the WebKit remote process disconnecting.
    var useSimpleRenderer: Bool = false
    @State private var showCopied: Bool = false
    
    @Bindable private var settings = AppSettings.shared
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if message.role == "user" {
                // ── User prompt label ──────────────────────────────────
                HStack(spacing: 6) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                    Text(message.content)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                    Spacer()
                }
                .padding(.top, 4)

            } else {
                // ── Assistant output ───────────────────────────────────
                Group {
                    let assistantTextColor: Color = settings.themeStyle == .gradient ? .white : .primary
                    
                    if message.isStreaming && message.content.isEmpty {
                        EmptyView()
                    } else if message.isStreaming || useSimpleRenderer {
                        Text(message.content)
                            .font(.system(size: fontSize))
                            .foregroundStyle(assistantTextColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                    } else {
                        RichMarkdownView(text: message.content, fontSize: fontSize)
                            .foregroundStyle(assistantTextColor)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                    }
                }

                // ── Per-message copy ───────────────────────────────────
                if !hideCopyButton && !message.isStreaming && !message.content.isEmpty {
                    HStack {
                        Spacer()
                        Button {
                            let pb = NSPasteboard.general
                            pb.prepareForNewContents(with: [])
                            pb.writeObjects([message.content as NSString])
                            showCopied = true
                            Task { @MainActor in
                                try? await Task.sleep(for: .seconds(1.5))
                                showCopied = false
                            }
                        } label: {
                            Label(showCopied ? "Copied" : "Copy", systemImage: showCopied ? "checkmark" : "doc.on.doc")
                                .font(.system(size: 11))
                                .foregroundStyle(showCopied ? AnyShapeStyle(Color.green) : AnyShapeStyle(.tertiary))
                        }
                        .buttonStyle(.plain)
                        .animation(.easeInOut(duration: 0.15), value: showCopied)
                    }
                    .padding(.top, 2)
                }
            }
        }
        .contextMenu {
            Button("Copy Message") {
                let pb = NSPasteboard.general
                pb.prepareForNewContents(with: [])
                pb.writeObjects([message.content as NSString])
            }
        }
    }
}

// MARK: - Thinking Indicator

struct ThinkingIndicator: View {
    @State private var phase: Int = 0

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Color.secondary.opacity(phase == i ? 0.8 : 0.3))
                    .frame(width: 5, height: 5)
                    .scaleEffect(phase == i ? 1.2 : 0.9)
                    .animation(.easeInOut(duration: 0.4).repeatForever(autoreverses: false).delay(Double(i) * 0.15), value: phase)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 0.45).repeatForever(autoreverses: false)) {
                phase = (phase + 1) % 3
            }
        }
    }
}

// MARK: - Follow-up Input Bar

struct FollowUpInputBar: View {
    @Binding var text: String
    let isDisabled: Bool
    let isLoading: Bool
    let onSubmit: () -> Void
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: 8) {
            TextField("Ask a follow-up…", text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .focused($focused)
                .disabled(isDisabled)
                .onSubmit(onSubmit)
                .padding(.leading, 12)
                .padding(.vertical, 8)

            if isLoading {
                ProgressView()
                    .controlSize(.small)
                    .scaleEffect(0.75)
                    .padding(.trailing, 10)
            } else if !text.isEmpty {
                Button(action: onSubmit) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.accentColor)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 8)
                .transition(.scale(scale: 0.7).combined(with: .opacity))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.primary.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(
                            focused ? Color.accentColor.opacity(0.5) : Color.primary.opacity(0.1),
                            lineWidth: 0.75
                        )
                )
        )
        .animation(.easeInOut(duration: 0.15), value: focused)
        .animation(.spring(response: 0.25), value: text.isEmpty)
    }
}

// MARK: - Rich Markdown View

struct RichMarkdownView: View {
    let text: String
    let fontSize: CGFloat

    var body: some View {
        MarkdownView(text)
            .markdownMathRenderingEnabled()
            .font(.system(size: fontSize), for: .body)
            .font(.system(size: fontSize * 1.4, weight: .bold), for: .h1)
            .font(.system(size: fontSize * 1.25, weight: .bold), for: .h2)
            .font(.system(size: fontSize * 1.15, weight: .semibold), for: .h3)
            .font(.system(size: fontSize * 1.1, weight: .semibold), for: .h4)
            .font(.system(size: fontSize * 1.05, weight: .medium), for: .h5)
            .font(.system(size: fontSize, weight: .medium), for: .h6)
            .font(.system(size: fontSize, design: .monospaced), for: .codeBlock)
            .font(.system(size: fontSize), for: .blockQuote)
            .font(.system(size: fontSize, weight: .semibold), for: .tableHeader)
            .font(.system(size: fontSize), for: .tableBody)
            .font(.system(size: fontSize), for: .inlineMath)
            .font(.system(size: fontSize + 2), for: .displayMath)
            .tint(.primary, for: .inlineCodeBlock)
    }
}