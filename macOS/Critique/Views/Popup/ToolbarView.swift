import SwiftUI



struct ToolbarView: View {
    @Bindable var appState: AppState
    @State private var customText: String = ""
    @State private var isProcessing: Bool = false
    @State private var selectedCommandID: UUID? = nil

    @Bindable private var settings = AppSettings.shared
    @Environment(\.colorScheme) var colorScheme

    let closeAction: () -> Void
    let moreAction: () -> Void

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

    // MARK: - Gradient Theme Helpers
    private var isGradient: Bool { settings.themeStyle == .gradient }
    
    private var primaryColor: Color {
        isGradient ? .white : .primary
    }
    
    private var secondaryColor: Color {
        isGradient ? .white.opacity(0.8) : .secondary
    }
    
    private var backgroundStyle: AnyShapeStyle {
        isGradient ? AnyShapeStyle(Color.white.opacity(0.18)) : AnyShapeStyle(.quaternary)
    }

    var body: some View {
        HStack(spacing: 0) {
            // ── Text input ──────────────────────────────────────────────
            ZStack(alignment: .leading) {
                if customText.isEmpty {
                    Text("Ask Critique...")
                        .foregroundStyle(secondaryColor)
                        .padding(.leading, 14)
                }
                
                TextField(
                    "",
                    text: $customText
                )
                .textFieldStyle(.plain)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(primaryColor)
                .padding(.leading, 14)
                .padding(.trailing, 8)
                .onSubmit { runCustomAction() }
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
                        
                        Image(systemName: selectedCommand?.icon ?? "sparkles")
                            .font(DesignSystem.iconFont)
                            .foregroundStyle(primaryColor)
                    }
                    .frame(width: DesignSystem.buttonSize, height: DesignSystem.buttonSize)
                } else {
                    let hasIcon = settings.commandDisplayStyle != .textOnly
                    HStack(spacing: 4) {
                        if hasIcon {
                            Image(systemName: selectedCommand?.icon ?? "sparkles")
                                .font(DesignSystem.iconFont)
                                .foregroundStyle(primaryColor)
                        }
                        Text(selectedCommand?.name ?? "Tone")
                            .font(DesignSystem.iconFont)
                            .foregroundStyle(primaryColor)
                            
                        Image(systemName: "chevron.down")
                            .font(DesignSystem.chevronFont)
                            .foregroundStyle(secondaryColor)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(backgroundStyle)
                    )
                }
            }
            .buttonStyle(.plain)
            .padding(.leading, 4)
            .padding(.trailing, 2)

            // ── Submit ──────────────────────────────────────────────────
            Button {
                if !customText.isEmpty {
                    runCustomAction()
                } else if let command = selectedCommand {
                    execute(command)
                }
            } label: {
                Group {
                    if isProcessing {
                        ProgressView()
                            .controlSize(.small)
                            .scaleEffect(0.7)
                    } else {
                        ZStack {
                            Circle()
                                .fill(backgroundStyle)
                                .opacity((selectedCommand != nil && !isProcessing) ? 1.0 : 0.4)
                            
                            Image(systemName: "arrow.up")
                                .font(DesignSystem.buttonIconFont)
                                .foregroundStyle(primaryColor)
                        }
                    }
                }
                .frame(width: DesignSystem.buttonSize, height: DesignSystem.buttonSize)

            }
            .buttonStyle(.plain)
            .disabled(selectedCommand == nil || isProcessing)
            .padding(.leading, 2)
            .padding(.trailing, 8) 
        }
        .frame(height: DesignSystem.pillHeight)
        .windowBackground(shape: Capsule())
        .overlay(
            Capsule()
                .strokeBorder(DesignSystem.tokens(for: settings.themeStyle).borderColor(colorScheme), lineWidth: 1.0)
        )
        // Shadow is now handled by the windowBackground modifier which pulls from DesignSystem
        .padding(.horizontal, 2)
    }

    // MARK: - Helpers

    private func updateSelection(to command: CommandModel) {
        selectedCommandID = command.id
    }

    private func runCustomAction() {
        guard !isProcessing, !customText.isEmpty else { return }
        let customCommand = CommandModel(
            name: "Critique Instruction",
            prompt: customText,
            icon: "sparkles",
            isBuiltIn: false
        )
        execute(customCommand)
    }

    private func execute(_ command: CommandModel) {
        isProcessing = true
        Task { @MainActor in
            do {
                try await CommandExecutionEngine.shared.executeCommand(
                    command,
                    source: .popup,
                    closePopupOnInlineCompletion: closeAction
                )
            } catch {
                print("Execution failed: \(error)")
            }
            isProcessing = false
        }
    }
}