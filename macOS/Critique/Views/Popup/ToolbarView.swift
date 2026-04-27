import SwiftUI
import AppKit



struct ToolbarView: View {
    @Bindable var appState: AppState
    @State private var customText: String = ""
    @State private var isProcessing: Bool = false
    @State private var selectedCommandID: UUID? = nil
    @State private var executionTask: Task<Void, Never>? = nil

    @Bindable private var settings = AppSettings.shared
    @Environment(\.colorScheme) var colorScheme

    let closeAction: () -> Void
    let moreAction: () -> Void

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
                    onSubmit: runCustomAction
                )
                .padding(.leading, 14)
                .padding(.trailing, 8)
                .opacity(isProcessing ? 0.01 : 1)
                .allowsHitTesting(!isProcessing)
            }
            .frame(minWidth: 100)

            // ── Tone picker ─────────────────────────────────────────────
            Menu {
                Section("Tone") {
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

            // ── Submit ──────────────────────────────────────────────────
            Button {
                if isProcessing {
                    stopProcessing()
                } else if !customText.isEmpty {
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
            .buttonStyle(.plain)
            .disabled(selectedCommand == nil && !isProcessing)
            .padding(.leading, 2)
            .padding(.trailing, 8) 
        }
        .frame(height: DesignSystem.pillHeight)
        .windowBackground(shape: Capsule())
        .overlay(
            Capsule()
                .strokeBorder(themeTokens.borderColor(colorScheme), lineWidth: 1.0)
        )
        // Shadow is now handled by the windowBackground modifier which pulls from DesignSystem
        .padding(.horizontal, 2)
    }

    // MARK: - Helpers

    private func updateSelection(to command: CommandModel) {
        selectedCommandID = command.id
    }

    private func runCustomAction() {
        guard !customText.isEmpty else { return }
        let promptToRun = customText
        customText = "" // Clear to show "Critiquing..." placeholder
        
        Task {
            do {
                try await CommandExecutionEngine.shared.executeCustomInstruction(
                    promptToRun,
                    source: .popup,
                    openInResponseWindow: settings.openCustomCommandsInResponseView,
                    closePopupOnInlineCompletion: closeAction
                )
            } catch {
                print("Custom action failed: \(error)")
            }
        }
    }

    private func stopProcessing() {
        executionTask?.cancel()
        executionTask = nil
        appState.activeProvider.cancel()
        appState.isProcessing = false
        isProcessing = false
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
                try await CommandExecutionEngine.shared.executeCommand(
                    command,
                    source: .popup,
                    closePopupOnInlineCompletion: closeAction
                )
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

private struct ToolbarInputField: NSViewRepresentable {
    @Binding var text: String
    let textColor: NSColor
    let cursorColor: NSColor
    let isEditable: Bool
    let onSubmit: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onSubmit: onSubmit)
    }

    func makeNSView(context: Context) -> PremiumToolbarTextField {
        let textField = PremiumToolbarTextField()
        textField.delegate = context.coordinator
        textField.target = context.coordinator
        textField.action = #selector(Coordinator.submit)
        textField.isBordered = false
        textField.drawsBackground = false
        textField.focusRingType = .none
        textField.bezelStyle = .roundedBezel
        textField.font = NSFont.systemFont(ofSize: 13, weight: .regular)
        textField.lineBreakMode = .byTruncatingTail
        textField.maximumNumberOfLines = 1
        textField.usesSingleLineMode = true
        textField.isAutomaticTextCompletionEnabled = false
        textField.cell?.wraps = false
        return textField
    }

    func updateNSView(_ nsView: PremiumToolbarTextField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }

        nsView.textColor = textColor
        nsView.insertionPointColor = cursorColor
        nsView.isEditable = isEditable
        nsView.isSelectable = isEditable

        if isEditable {
            nsView.alphaValue = 1
        } else {
            if nsView.window?.firstResponder === nsView.currentEditor() {
                nsView.window?.makeFirstResponder(nil)
            }
            nsView.alphaValue = 0.01
        }
    }

    final class Coordinator: NSObject, NSTextFieldDelegate {
        @Binding var text: String
        let onSubmit: () -> Void

        init(text: Binding<String>, onSubmit: @escaping () -> Void) {
            self._text = text
            self.onSubmit = onSubmit
        }

        func controlTextDidChange(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            text = textField.stringValue
        }

        @objc func submit() {
            onSubmit()
        }
    }
}

private final class PremiumToolbarTextField: NSTextField {
    var insertionPointColor: NSColor = .white {
        didSet { applyInsertionPointColor() }
    }

    override func becomeFirstResponder() -> Bool {
        let becameFirstResponder = super.becomeFirstResponder()
        applyInsertionPointColor()
        return becameFirstResponder
    }

    override func textDidBeginEditing(_ notification: Notification) {
        super.textDidBeginEditing(notification)
        applyInsertionPointColor()
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        applyInsertionPointColor()
    }

    private func applyInsertionPointColor() {
        (currentEditor() as? NSTextView)?.insertionPointColor = insertionPointColor
    }
}
