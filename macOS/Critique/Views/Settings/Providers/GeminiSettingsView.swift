//
//  GeminiSettingsView.swift
//  Critique
//
//  Created by Arya Mirsepasi on 04.11.25.
//

import SwiftUI

struct GeminiSettingsView: View {
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
                    Picker("", selection: $settings.geminiModel) {
                        ForEach(GeminiModel.allCases, id: \.self) { model in
                            Text(model.displayName).tag(model)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .frame(width: 250, alignment: .leading)
                    .onChange(of: settings.geminiModel) { _, _ in
                        needsSaving = true
                    }
                    
                    if settings.geminiModel == .custom {
                        TextField("Custom Model Name", text: $settings.geminiCustomModel)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 250)
                            .onChange(of: settings.geminiCustomModel) { _, _ in
                                needsSaving = true
                            }
                    }
                }
                .frame(width: 250, alignment: .leading)
            }
            
            // API Key Configuration
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
                    SecureAPIKeyField("Enter your Gemini API key", text: $settings.geminiApiKey)
                        .frame(width: 250)
                        .onChange(of: settings.geminiApiKey) { _, _ in
                            needsSaving = true
                        }
                    
                    Button("Get API Key") {
                        if let url = URL(string: "https://aistudio.google.com/app/apikey") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .buttonStyle(.link)
                    .font(.caption)
                    .help("Open Google AI Studio to generate an API key.")
                }
                .frame(width: 250, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
