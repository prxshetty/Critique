import SwiftUI
import AppKit



struct ToolbarView: View {
    @Bindable var appState: AppState
    @State private var customText: String = ""
    @State private var isProcessing: Bool = false
    @State private var selectedCommandID: UUID? = nil
    @State private var executionTask: Task<Void, Never>? = nil
    @State private var inlineResponseViewModel: ResponseViewModel? = nil

    @Bindable private var settings = AppSettings.shared
    @Environment(\.colorScheme) private var colorScheme

    let closeAction: () -> Void
    let moreAction: () -> Void
    let viewModel: PopupViewModel

    private var themeTokens: DesignSystem.ThemeTokens {
        DesignSystem.tokens(for: settings.themeStyle)
    }

    private var selectedCommand: CommandModel? {
        if let localId = selectedCommandID, let local = appState.commandManager.commands.first(where: { $0.id == localId }) {
            return local
        }
        if let customId = settings.primaryCommandID {
            if let custom = appState.commandManager.customCommands.first(where: { $0.id == customId }) {
                return custom
            }
        }
        return appState.commandManager.commands.first { $0.name == settings.primaryTone.localizedName }
    }

    private var sortedCommands: [CommandModel] {
        let all = appState.commandManager.commands
        let active = selectedCommand
        let other = all.filter { $0.id != active?.id }
        if let active = active {
            return [active] + other
        }
        return other
    }

    // MARK: - Theme Helpers
    private var isGradient: Bool { settings.themeStyle == .gradient }
    private var isGlass: Bool { settings.themeStyle == .glass }
    private var isOLED: Bool { settings.themeStyle == .oled }
    private var isStandard: Bool { settings.themeStyle == .standard }
    
    private var primaryColor: Color {
        if isGradient {
            return .white.opacity(0.9)
        }
        if isGlass {
            return colorScheme == .light
                ? Color(nsColor: .labelColor)
                : Color(nsColor: .textColor)
        }
        return .primary
    }
    
    private var secondaryColor: Color {
        if isGradient {
            return .white.opacity(0.6)
        }
        if isGlass {
            return colorScheme == .light
                ? Color(nsColor: .secondaryLabelColor)
                : Color(nsColor: .secondaryLabelColor)
        }
        return .secondary
    }

    private var loadingPlaceholderColor: Color {
        themeTokens.toolbarLoadingTextColor(colorScheme)
            .opacity(themeTokens.toolbarLoadingTextBaseOpacity)
    }
    
    private var backgroundStyle: AnyShapeStyle {
        if isOLED {
            return AnyShapeStyle(Color.clear)
        }
        if isGradient {
            return AnyShapeStyle(Color.white.opacity(0.18))
        }
        if isGlass {
            return AnyShapeStyle(
                colorScheme == .light
                    ? Color.black.opacity(0.06)
                    : Color.white.opacity(0.08)
            )
        }
        return AnyShapeStyle(.quaternary)
    }

    private var controlBorderColor: Color {
        if isOLED {
            return colorScheme == .light
                ? Color.black.opacity(0.12)
                : Color.white.opacity(0.18)
        }
        return .clear
    }

    private var standardSubmitBackgroundColor: Color {
        colorScheme == .light ? Color.black.opacity(0.9) : Color.white.opacity(0.92)
    }

    private var standardSubmitIconColor: Color {
        colorScheme == .light ? Color.white : Color.black.opacity(0.88)
    }

    private var textCursorColor: NSColor {
        if isGradient {
            return NSColor.white.withAlphaComponent(0.95)
        }
        if isGlass {
            return colorScheme == .light
                ? NSColor.labelColor.withAlphaComponent(0.9)
                : NSColor.white.withAlphaComponent(0.95)
        }
        return colorScheme == .dark
            ? NSColor.white.withAlphaComponent(0.92)
            : NSColor.labelColor
    }

    var body: some View {
        VStack(spacing: 0) {
            if let inlineVM = inlineResponseViewModel {
                InlineResponseView(viewModel: inlineVM, popupViewModel: viewModel, closeAction: closeAction)
                .frame(maxHeight: 300)
                Divider().opacity(0.5)
            }
            HStack(spacing: 0) {
                // ── Text input ──────────────────────────────────────────────
                ZStack(alignment: .leading) {
                    if customText.isEmpty {
                        Text(isProcessing ? "Critiquing..." : "Ask Critique...")
                            .foregroundStyle(isProcessing ? loadingPlaceholderColor : secondaryColor)
                            .padding(.leading, 14)
                            .shimmer(
                                isActive: isProcessing,
                                baseColor: themeTokens.toolbarLoadingTextColor(colorScheme),
                                leadingOpacity: themeTokens.toolbarShimmerLeadingOpacity,
                                midOpacity: themeTokens.toolbarShimmerMidOpacity,
                                peakOpacity: themeTokens.toolbarShimmerPeakOpacity,
                                trailingOpacity: themeTokens.toolbarShimmerTrailingOpacity,
                                duration: themeTokens.toolbarShimmerDuration
                            )
                    }

                    ToolbarInputField(
                        text: $customText,
                        textColor: NSColor(primaryColor),
                        cursorColor: textCursorColor,
                        isEditable: !isProcessing,
                        onSubmit: {
                            if let inlineVM = inlineResponseViewModel {
                                let prompt = customText.trimmingCharacters(in: .whitespacesAndNewlines)
                                if prompt.isEmpty {
                                    // If empty, check if we should "Accept" the response via Enter
                                    if settings.enterToAcceptInlineResponse {
                                        replaceContent(using: inlineVM)
                                    }
                                } else {
                                    customText = ""
                                    isProcessing = true
                                    inlineVM.startFollowUpQuestion(
                                        prompt,
                                        onCompletion: { isProcessing = false },
                                        onFailure: { _ in isProcessing = false }
                                    )
                                }
                            } else {
                                runCustomAction()
                            }
                        }
                    )
                    .padding(.leading, 14)
                    .padding(.trailing, 8)
                    .opacity(isProcessing ? 0.01 : 1)
                    .allowsHitTesting(!isProcessing)
                }
                .frame(minWidth: 100)

                // ── Tone picker or Replace button ───────────────────────────────────────────
                if let inlineVM = inlineResponseViewModel {
                    Button {
                        replaceContent(using: inlineVM)
                    } label: {
                        if settings.commandDisplayStyle == .iconOnly {
                            ZStack {
                                Circle()
                                    .fill(backgroundStyle)
                                    .overlay {
                                        if isOLED {
                                            Circle()
                                                .strokeBorder(controlBorderColor, lineWidth: 1.0)
                                        }
                                    }
                                
                                Image(systemName: "arrow.right.doc.on.clipboard")
                                    .font(DesignSystem.iconFont)
                                    .foregroundStyle(secondaryColor)
                            }
                            .frame(width: DesignSystem.buttonSize, height: DesignSystem.buttonSize)
                        } else {
                            let hasIcon = settings.commandDisplayStyle != .textOnly
                            HStack(spacing: 4) {
                                if hasIcon {
                                    Image(systemName: "arrow.right.doc.on.clipboard")
                                        .font(DesignSystem.iconFont)
                                        .foregroundStyle(secondaryColor)
                                }
                                Text("Replace")
                                    .font(DesignSystem.iconFont)
                                    .foregroundStyle(secondaryColor)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .frame(maxWidth: 80)
                            }
                            .fixedSize()
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(backgroundStyle)
                                    .overlay {
                                        if isOLED {
                                            Capsule()
                                                .strokeBorder(controlBorderColor, lineWidth: 1.0)
                                        }
                                    }
                            )
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 4)
                    .padding(.trailing, 2)
                    .disabled(isProcessing)
                    .help("Replace selected text with the latest response")
                } else {
                    Menu {
                        ForEach(sortedCommands) { command in
                            Button {
                                updateSelection(to: command)
                            } label: {
                                Label(command.name, systemImage: command.icon)
                                if command.id == selectedCommand?.id {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    } label: {
                        if settings.commandDisplayStyle == .iconOnly {
                            ZStack {
                                Circle()
                                    .fill(backgroundStyle)
                                    .overlay {
                                        if isOLED {
                                            Circle()
                                                .strokeBorder(controlBorderColor, lineWidth: 1.0)
                                        }
                                    }
                                
                                Image(systemName: selectedCommand?.icon ?? "sparkles")
                                    .font(DesignSystem.iconFont)
                                    .foregroundStyle(secondaryColor)
                            }
                            .frame(width: DesignSystem.buttonSize, height: DesignSystem.buttonSize)
                        } else {
                            let hasIcon = settings.commandDisplayStyle != .textOnly
                            HStack(spacing: 4) {
                                if hasIcon {
                                    Image(systemName: selectedCommand?.icon ?? "sparkles")
                                        .font(DesignSystem.iconFont)
                                        .foregroundStyle(secondaryColor)
                                }
                                Text(selectedCommand?.name ?? "Tone")
                                    .font(DesignSystem.iconFont)
                                    .foregroundStyle(secondaryColor)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .frame(maxWidth: 80)
                                    
                                Image(systemName: "chevron.down")
                                    .font(DesignSystem.chevronFont)
                                    .foregroundStyle(secondaryColor)
                            }
                            .fixedSize()
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(backgroundStyle)
                                    .overlay {
                                        if isOLED {
                                            Capsule()
                                                .strokeBorder(controlBorderColor, lineWidth: 1.0)
                                        }
                                    }
                            )
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 4)
                    .padding(.trailing, 2)
                }
                // ── Submit ──────────────────────────────────────────────────
                Button {
                    if isProcessing {
                        stopProcessing()
                    } else if let inlineVM = inlineResponseViewModel, !customText.isEmpty {
                        let prompt = customText
                        customText = ""
                        isProcessing = true
                        inlineVM.startFollowUpQuestion(
                            prompt,
                            onCompletion: { isProcessing = false },
                            onFailure: { _ in isProcessing = false }
                        )
                    }
                    else if !customText.isEmpty {
                        runCustomAction()
                    } else if let command = selectedCommand {
                        execute(command)
                    }
                } label: {
                    Group {
                        if isProcessing {
                            ZStack {
                                Circle()
                                    .fill(isStandard ? AnyShapeStyle(standardSubmitBackgroundColor) : backgroundStyle)
                                    .overlay {
                                        if isOLED {
                                            Circle()
                                                .strokeBorder(controlBorderColor, lineWidth: 1.0)
                                        }
                                    }
                                
                                Image(systemName: "square.fill")
                                    .font(DesignSystem.buttonIconFont)
                                    .foregroundStyle(isStandard ? standardSubmitIconColor : secondaryColor)
                            }
                        } else {
                            ZStack {
                                Circle()
                                    .fill(isStandard ? AnyShapeStyle(standardSubmitBackgroundColor) : backgroundStyle)
                                    .overlay {
                                        if isOLED {
                                            Circle()
                                                .strokeBorder(controlBorderColor, lineWidth: 1.0)
                                        }
                                    }
                                    .opacity((selectedCommand != nil) ? 1.0 : 0.4)
                                
                                Image(systemName: "arrow.up")
                                    .font(DesignSystem.buttonIconFont)
                                    .foregroundStyle(isStandard ? standardSubmitIconColor : secondaryColor)
                            }
                        }
                    }
                    .frame(width: DesignSystem.buttonSize, height: DesignSystem.buttonSize)
                }
            }
            .buttonStyle(.plain)
            .disabled(selectedCommand == nil && !isProcessing)
            .padding(.leading, 2)
            .padding(.trailing, 8)         
            .frame(height: DesignSystem.pillHeight)
        }
        .windowBackground(shape: inlineResponseViewModel != nil ?
        AnyShape(RoundedRectangle(cornerRadius: 16)) : AnyShape(Capsule()))
        .overlay(
            Group {
                if inlineResponseViewModel != nil {
                    RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(themeTokens.borderColor(colorScheme), lineWidth: 1.0)
                } else {
                    Capsule()
                        .strokeBorder(themeTokens.borderColor(colorScheme), lineWidth: 1.0)
                }
            }
        )
        .onChange(of: inlineResponseViewModel != nil) { _, active in
            viewModel.inlineResponseActive = active
        }
    }

    // MARK: - Helpers

    private func updateSelection(to command: CommandModel) {
        selectedCommandID = command.id
    }

    private func runCustomAction() {
        guard !customText.isEmpty else { return }
        let promptToRun = customText
        customText = "" // Clear to show "Critiquing..." placeholder

        isProcessing = true
        executionTask = Task { @MainActor in
            defer {
                isProcessing = false
                executionTask = nil
            }

            let systemPrompt = CommandExecutionEngine.customInstructionSystemPrompt

            let selectedText = appState.selectedText
            let userPrompt = selectedText.isEmpty
                ? promptToRun
                : "User's instruction: \(promptToRun) \n\nText:\n\(selectedText)"

            if settings.openManualInstructionsInResponseView || settings.useMultiIteration {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    self.inlineResponseViewModel = ResponseViewModel(
                        selectedText: selectedText,
                        option: nil,
                        provider: appState.activeProvider,
                        systemPrompt: systemPrompt,
                        userPrompt: userPrompt,
                        images: appState.selectedImages,
                        continuationSystemPrompt: systemPrompt
                    )
                }
            } else {
                // Direct replacement path for custom instructions
                do {
                    let text = try await appState.activeProvider.processText(
                        systemPrompt: systemPrompt,
                        userPrompt: userPrompt,
                        images: appState.selectedImages,
                        streaming: false
                    )
                    appState.replaceSelectedText(with: text)
                } catch {
                    print("Custom action failed: \(error)")
                }
            }
        }
    }

    private func stopProcessing() {
        executionTask?.cancel()
        executionTask = nil
        inlineResponseViewModel?.cancelOngoingTasks()
        appState.activeProvider.cancel()
        appState.isProcessing = false
        isProcessing = false
    }

    private func replaceContent(using viewModel: ResponseViewModel) {
        // Extract only the MOST RECENT assistant response
        guard let lastAssistantMessage = viewModel.messages.last(where: { $0.role == "assistant" })?.content,
              !lastAssistantMessage.isEmpty else { return }

        // Use AppState to perform the inline replacement
        let state = appState
        if state.selectedAttributedText != nil { 
            state.replaceSelectedTextPreservingAttributes(with: lastAssistantMessage)
        } else {
            state.replaceSelectedText(with: lastAssistantMessage)
        }

        closeAction()
    }


    private func execute(_ command: CommandModel) {
        executionTask?.cancel()
        isProcessing = true
        
        executionTask = Task { @MainActor in
            defer {
                isProcessing = false
                executionTask = nil
            }
            
            do {
                let input = try await appState.resolveCommandInput(mode: .textOrImagesWithOCRFallback)
                let provider = appState.getProvider(for: command)

                // Determine if we should show in window or replace directly
                let shouldShowInWindow = command.useResponseWindow || 
                                       (command.isBuiltIn ? settings.openBuiltInCommandsInResponseView : settings.openCustomCommandsInResponseView) ||
                                       settings.useMultiIteration

                if shouldShowInWindow {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        self.inlineResponseViewModel = ResponseViewModel(
                            selectedText: appState.selectedText,
                            option: nil,
                            provider: provider,
                            systemPrompt: command.prompt,
                            userPrompt: input.userPrompt,
                            images: input.images,
                            continuationSystemPrompt: command.prompt
                        )
                    }
                } else {
                    // Direct replacement path
                    let text = try await provider.processText(
                        systemPrompt: command.prompt,
                        userPrompt: input.userPrompt,
                        images: input.images,
                        streaming: false
                    )
                    
                    appState.replaceSelectedText(with: text)
                    
                    // Reset selection after direct replacement
                    self.selectedCommandID = nil
                }
            } catch is CancellationError {
                // Ignore cancellation - user clicked stop
            } catch {
                print("Execution failed: \(error)")
            }
        }
    }
}

// MARK: - Shimmer Effect

extension View {
    @ViewBuilder
    func shimmer(
        isActive: Bool,
        baseColor: Color = .white,
        leadingOpacity: Double = 0.18,
        midOpacity: Double = 0.55,
        peakOpacity: Double = 1.0,
        trailingOpacity: Double = 0.4,
        duration: Double = 4.0
    ) -> some View {
        if isActive {
            self.overlay(
                GeometryReader { geo in
                    ShimmerOverlay(
                        baseColor: baseColor,
                        leadingOpacity: leadingOpacity,
                        midOpacity: midOpacity,
                        peakOpacity: peakOpacity,
                        trailingOpacity: trailingOpacity,
                        duration: duration
                    )
                        .frame(width: geo.size.width * 2)
                        .offset(x: -geo.size.width)
                }
                .clipped()
                .allowsHitTesting(false)
            )
            .mask(self)
        } else {
            self
        }
    }
}

struct ShimmerOverlay: View {
    let baseColor: Color
    let leadingOpacity: Double
    let midOpacity: Double
    let peakOpacity: Double
    let trailingOpacity: Double
    let duration: Double

    @State private var travel: CGFloat = -1.2

    var body: some View {
        GeometryReader { geometry in
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0.0),
                    .init(color: baseColor.opacity(leadingOpacity), location: 0.24),
                    .init(color: baseColor.opacity(midOpacity), location: 0.43),
                    .init(color: baseColor.opacity(peakOpacity), location: 0.5),
                    .init(color: baseColor.opacity(trailingOpacity), location: 0.57),
                    .init(color: .clear, location: 0.82),
                    .init(color: .clear, location: 1.0),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: geometry.size.width * 0.72, height: geometry.size.height * 2.1)
            .rotationEffect(.degrees(-14))
            .blendMode(.plusLighter)
            .blur(radius: 4)
            .offset(x: geometry.size.width * travel)
        }
        .onAppear {
            travel = -1.2
            withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                travel = 1.4
            }
        }
    }
}

