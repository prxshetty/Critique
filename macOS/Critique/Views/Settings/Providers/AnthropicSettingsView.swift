//
//  AnthropicSettingsView.swift
//  Critique
//
//  Created by Arya Mirsepasi on 04.11.25.
//

import SwiftUI
import AppKit

struct AnthropicSettingsView: View {
    @Bindable var settings = AppSettings.shared
    @Binding var needsSaving: Bool
    @State private var modelSelection: AnthropicModel

    init(needsSaving: Binding<Bool>) {
        self._needsSaving = needsSaving
        // Initialize model selection from current settings to avoid flash on appear
        let currentModel = AppSettings.shared.anthropicModel
        if let knownModel = AnthropicModel(rawValue: currentModel), knownModel != .custom {
            self._modelSelection = State(initialValue: knownModel)
        } else {
            self._modelSelection = State(initialValue: .custom)
        }
    }

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 16) {
            // Model Selection
            GridRow {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Model:")
                        .foregroundStyle(.secondary)
                    Text("Selection")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .gridColumnAlignment(.trailing)
                .frame(width: 110, alignment: .trailing)
                
                VStack(alignment: .leading, spacing: 4) {
                    Picker("", selection: $modelSelection) {
                        ForEach(AnthropicModel.allCases, id: \.self) { model in
                            Text(model.displayName).tag(model)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .frame(width: 250, alignment: .leading)
                    .onChange(of: modelSelection) { _, newValue in
                        if newValue != .custom {
                            settings.anthropicModel = newValue.rawValue
                        }
                        needsSaving = true
                    }
                    
                    if modelSelection == .custom {
                        TextField("Custom Model Name", text: $settings.anthropicModel)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 250)
                            .onChange(of: settings.anthropicModel) { _, _ in needsSaving = true }
                    }
                    Text("e.g., \(AnthropicModel.claude45Haiku.rawValue), \(AnthropicModel.claude45Sonnet.rawValue)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: 250, alignment: .leading)
                }
                .frame(width: 250, alignment: .leading)
            }
            
            // API Configuration
            GridRow {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("API Key:")
                        .foregroundStyle(.secondary)
                    Text("Authentication")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .gridColumnAlignment(.trailing)
                .frame(width: 110, alignment: .trailing)
                
                VStack(alignment: .leading, spacing: 8) {
                    SecureAPIKeyField("Enter your Anthropic API key", text: $settings.anthropicApiKey)
                        .frame(width: 250)
                        .onChange(of: settings.anthropicApiKey) { _, _ in needsSaving = true }
                    
                    Button("Get Anthropic API Key") {
                        if let url = URL(string: "https://console.anthropic.com/settings/keys") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .buttonStyle(.link)
                    .font(.caption)
                    .help("Open Anthropic console to create or view your API key.")
                }
                .frame(width: 250, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .onAppear {
            syncModelSelection(settings.anthropicModel)
        }
        .onChange(of: settings.anthropicModel) { _, newValue in
            syncModelSelection(newValue)
        }
    }

    private func syncModelSelection(_ modelName: String) {
        if let knownModel = AnthropicModel(rawValue: modelName), knownModel != .custom {
            modelSelection = knownModel
        } else {
            modelSelection = .custom
        }
    }
}
