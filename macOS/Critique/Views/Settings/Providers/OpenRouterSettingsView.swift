//
//  OpenRouterSettingsView.swift
//  Critique
//
//  Created by Arya Mirsepasi on 04.11.25.
//

import SwiftUI
import AppKit

struct OpenRouterSettingsView: View {
    @Bindable var settings = AppSettings.shared
    @Binding var needsSaving: Bool

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
                    Picker("", selection: $settings.openRouterModel) {
                        ForEach(OpenRouterModel.allCases, id: \.self) { model in
                            Text(model.displayName).tag(model.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .frame(width: 250, alignment: .leading)
                    .onChange(of: settings.openRouterModel) { _, _ in needsSaving = true }
                    
                    if settings.openRouterModel == OpenRouterModel.custom.rawValue {
                        TextField("Custom Model Name", text: $settings.openRouterCustomModel)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 250)
                            .onChange(of: settings.openRouterCustomModel) { _, _ in needsSaving = true }
                    }
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
                    SecureAPIKeyField("Enter your OpenRouter API key", text: $settings.openRouterApiKey)
                        .frame(width: 250)
                        .onChange(of: settings.openRouterApiKey) { _, _ in needsSaving = true }
                    
                    Button("Get OpenRouter API Key") {
                        if let url = URL(string: "https://openrouter.ai/keys") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .buttonStyle(.link)
                    .font(.caption)
                    .help("Open OpenRouter to retrieve your API key.")
                }
                .frame(width: 250, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
