//
//  AIProviderSettingsPane.swift
//  Critique
//
//  Created by Arya Mirsepasi on 04.11.25.
//

import SwiftUI
import AppKit

struct AIProviderSettingsPane<SaveButton: View, CompleteSetupButton: View>: View {
    @Bindable var appState: AppState
    @Bindable var settings = AppSettings.shared
    @Binding var needsSaving: Bool
    var showOnlyApiSetup: Bool
    let saveButton: SaveButton
    let completeSetupButton: CompleteSetupButton

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
            // Provider Selection Form
            Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 16) {
                GridRow {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Provider:")
                            .foregroundStyle(.secondary)
                    }
                    .gridColumnAlignment(.trailing)
                    .frame(width: 110, alignment: .trailing)
                    
                    VStack(alignment: .leading) {
                        Picker("", selection: $settings.currentProvider) {
                            if settings.isAppleIntelligenceSupported {
                                Text("Apple Intelligence").tag("apple")
                            }
                            if LocalModelProvider.isAppleSilicon {
                                Text("Local LLM").tag("local")
                            }
                            Text("Gemini AI").tag("gemini")
                            Text("OpenAI").tag("openai")
                            Text("Anthropic").tag("anthropic")
                            Text("Mistral AI").tag("mistral")
                            Text("Ollama").tag("ollama")
                            Text("OpenRouter").tag("openrouter")
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .frame(width: 250, alignment: .leading)
                    }
                    .frame(width: 250, alignment: .leading)
                    .onChange(of: settings.currentProvider) { _, newValue in
                        if newValue == "local" && !LocalModelProvider.isAppleSilicon {
                            settings.currentProvider = "gemini"
                        }
                        needsSaving = true
                    }
                }
            }
            .padding(.top, 20)
            .frame(maxWidth: .infinity, alignment: .center)

            // Dynamic Provider Settings
            VStack(alignment: .leading, spacing: 0) {
                if settings.currentProvider == "apple" {
                    AppleIntelligenceSettingsView(settings: settings)
                } else if settings.currentProvider == "gemini" {
                    GeminiSettingsView(needsSaving: $needsSaving)
                } else if settings.currentProvider == "mistral" {
                    MistralSettingsView(needsSaving: $needsSaving)
                } else if settings.currentProvider == "anthropic" {
                    AnthropicSettingsView(needsSaving: $needsSaving)
                } else if settings.currentProvider == "openai" {
                    OpenAISettingsView(needsSaving: $needsSaving)
                } else if settings.currentProvider == "ollama" {
                    OllamaSettingsView(needsSaving: $needsSaving)
                } else if settings.currentProvider == "openrouter" {
                    OpenRouterSettingsView(needsSaving: $needsSaving)
                } else if settings.currentProvider == "local" {
                    LocalLLMSettingsView(provider: appState.localLLMProvider)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)

            Spacer()
        }
        .padding(.vertical, 24)
        }
    }
}
