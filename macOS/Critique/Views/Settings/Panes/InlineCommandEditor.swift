import SwiftUI
import KeyboardShortcuts

struct InlineCommandEditor: View {
    @Binding var command: CommandModel
    @Bindable var commandManager: CommandManager
    
    @State private var showingIconPicker = false
    @State private var showingRawPromptEditor = false
    @State private var rawPromptText = ""
    @FocusState private var isNameFieldFocused: Bool
    
    private var promptStructureBinding: Binding<PromptStructure> {
        Binding(
            get: { PromptStructure.from(jsonString: command.prompt) ?? .default },
            set: { command.prompt = $0.toJSONString(pretty: true) }
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header Content
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 20) {
                        // Icon Preview (Proportionate to multi-line content)
                        VStack {
                            Image(systemName: command.icon)
                                .font(.system(size: 32))
                                .frame(width: 64, height: 64)
                                .background(Color.primary.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        
                        // Content Stack
                        VStack(alignment: .leading, spacing: 8) {
                            // Title & Subtitle Group
                            VStack(alignment: .leading, spacing: 2) {
                                TextField("Command Name", text: $command.name)
                                    .font(.system(size: 22, weight: .bold))
                                    .textFieldStyle(.plain)
                                    .focused($isNameFieldFocused)
                                    .disabled(command.isBuiltIn)
                                
                                let taskText = promptStructureBinding.wrappedValue.task
                                Text(taskText.isEmpty ? "No prompt task configured" : taskText)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            
                            // Action Buttons (Now below metadata)
                            HStack(spacing: 8) {
                                if !command.isBuiltIn {
                                    Button(action: { isNameFieldFocused = true }) {
                                        Text("Rename")
                                    }
                                    .buttonStyle(PillButtonStyle())
                                }
                                
                                Button(action: { showingIconPicker = true }) {
                                    Text("Change Icon")
                                }
                                .buttonStyle(PillButtonStyle())
                                
                                Button(action: {
                                    rawPromptText = command.prompt
                                    showingRawPromptEditor = true
                                }) {
                                    Text("Edit Raw Prompt")
                                }
                                .buttonStyle(PillButtonStyle())
                            }
                            .padding(.top, 4)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                Divider()
                
                // Behavior Settings
                behaviorSection
                    .padding(.horizontal, 24)
                
                Divider()
                
                // AI Provider Section (Moved here)
                providerSection
                    .padding(.horizontal, 24)
                
                Divider()
                
                // Prompt Configuration
                VStack(alignment: .leading, spacing: 12) {
                    Text("Prompt Configuration")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    AdvancedPromptEditor(promptStructure: promptStructureBinding)
                }
                .padding(.horizontal, 24)
                
                if command.isBuiltIn {
                    Text("This is a built-in command. Changes are auto-saved, but you can reset built-in commands globally if needed.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                        .padding(.horizontal, 24)
                }
            }
            .padding(.bottom, 24)
        }
        .sheet(isPresented: $showingIconPicker) {
            IconPickerView(selectedIcon: $command.icon)
        }
        .sheet(isPresented: $showingRawPromptEditor) {
            rawPromptSheet
        }
    }
    
    private var rawPromptSheet: some View {
        VStack(spacing: 0) {
            Text("Raw Prompt Payload")
                .font(.headline)
                .padding()
            
            Divider()
            
            TextEditor(text: $rawPromptText)
                .font(.system(.body, design: .monospaced))
                .padding(12)
            
            Divider()
            
            HStack {
                Button("Cancel") {
                    showingRawPromptEditor = false
                }
                Spacer()
                Button("Save") {
                    command.prompt = rawPromptText
                    showingRawPromptEditor = false
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 500, height: 400)
    }
    
    private var behaviorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Behavior")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Toggle("Display response in window", isOn: $command.useResponseWindow)

            Toggle("Enable keyboard shortcut for this command", isOn: $command.hasShortcut)
                .onChange(of: command.hasShortcut) { _, newValue in
                    if !newValue {
                        KeyboardShortcuts.reset(.commandShortcut(for: command.id))
                    }
                }
            
            if command.hasShortcut {
                HStack(spacing: 12) {
                    Text("Shortcut:")
                        .frame(width: 80, alignment: .leading)
                    KeyboardShortcuts.Recorder(
                        for: .commandShortcut(for: command.id),
                        onChange: { shortcut in
                            if shortcut != nil {
                                command.hasShortcut = true
                            }
                        }
                    )
                    Spacer()
                }
            }
        }
    }
    // Extracted provider section to keep body readable
    private var providerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI Provider")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Toggle("Use custom AI provider", isOn: Binding(
                get: { command.providerOverride != nil },
                set: { enabled in
                    if enabled {
                        command.providerOverride = AppSettings.shared.currentProvider
                    } else {
                        command.providerOverride = nil
                        command.modelOverride = nil
                        command.customProviderBaseURL = nil
                        command.customProviderModel = nil
                    }
                }
            ))

            if let currentProvider = command.providerOverride {
                HStack(spacing: 12) {
                    Text("Provider:")
                        .frame(width: 80, alignment: .leading)
                    Picker("", selection: Binding(
                        get: { currentProvider },
                        set: { newProvider in
                            command.providerOverride = newProvider
                            if newProvider != "custom" {
                                command.customProviderBaseURL = nil
                                command.customProviderModel = nil
                            }
                        }
                    )) {
                        if LocalModelProvider.isAppleSilicon {
                            Text("Local LLM").tag("local")
                        }
                        Text("Gemini AI").tag("gemini")
                        Text("OpenAI").tag("openai")
                        Text("Anthropic").tag("anthropic")
                        Text("Mistral AI").tag("mistral")
                        Text("Ollama").tag("ollama")
                        Text("OpenRouter").tag("openrouter")
                        Text("Custom Provider").tag("custom")
                    }
                    .pickerStyle(.menu)
                    .frame(width: 200)
                    Spacer()
                }

                if currentProvider == "custom" {
                    customProviderFields
                } else {
                    HStack(spacing: 12) {
                        Text("Model:")
                            .frame(width: 80, alignment: .leading)
                        TextField("e.g., gpt-4o-mini", text: Binding(
                            get: { command.modelOverride ?? "" },
                            set: { newValue in
                                let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                                command.modelOverride = trimmed.isEmpty ? nil : trimmed
                            }
                        ))
                        .textFieldStyle(.roundedBorder)
                    }
                    Text("Leave empty to use the default model for the provider.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 92)
                }
            }
        }
    }
    
    private var customProviderFields: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Text("Base URL:")
                    .frame(width: 80, alignment: .leading)
                TextField("e.g., https://api.example.com", text: Binding(
                    get: { command.customProviderBaseURL ?? "" },
                    set: { command.customProviderBaseURL = $0.isEmpty ? nil : $0 }
                ))
                .textFieldStyle(.roundedBorder)
            }
            
            HStack(spacing: 12) {
                Text("API Key:")
                    .frame(width: 80, alignment: .leading)
                
                // Using an inline wrapper to handle Keychain sync for this specific command's API key
                CommandAPIKeyField(commandID: command.id)
            }
            
            HStack(spacing: 12) {
                Text("Model:")
                    .frame(width: 80, alignment: .leading)
                TextField("e.g., gpt-4o", text: Binding(
                    get: { command.customProviderModel ?? "" },
                    set: { command.customProviderModel = $0.isEmpty ? nil : $0 }
                ))
                .textFieldStyle(.roundedBorder)
            }
        }
        .padding(.top, 8)
    }
}

// Wrapper to bridge KeychainManager logic safely with SwiftUI
struct CommandAPIKeyField: View {
    let commandID: UUID
    @State private var localApiKey: String = ""
    
    var body: some View {
        SecureField("Your API key", text: $localApiKey)
            .textFieldStyle(.roundedBorder)
            .onAppear {
                localApiKey = KeychainManager.shared.retrieveCustomProviderApiKeySync(for: commandID) ?? ""
            }
            .onChange(of: localApiKey) { _, newValue in
                let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty {
                    KeychainManager.shared.deleteCustomProviderApiKeySync(for: commandID)
                } else {
                    KeychainManager.shared.saveCustomProviderApiKeySync(trimmed, for: commandID)
                }
            }
    }
}


fileprivate struct PillButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .foregroundStyle(.primary.opacity(0.8))
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.primary.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}