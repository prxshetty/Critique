//
//  OpenAISettingsView.swift
//  Critique
//
//  Created by Arya Mirsepasi on 04.11.25.
//

import SwiftUI
import AppKit

struct OpenAISettingsView: View {
    @Bindable var settings = AppSettings.shared
    @Binding var needsSaving: Bool

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 16) {
            // Model Configuration
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
                    TextField("Model Name", text: $settings.openAIModel)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 250)
                        .onChange(of: settings.openAIModel) { _, _ in
                            needsSaving = true
                        }
                    
                    Text("e.g., gpt-4o, gpt-4o-mini")
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
                    SecureAPIKeyField("Enter your OpenAI API key", text: $settings.openAIApiKey)
                        .frame(width: 250)
                        .onChange(of: settings.openAIApiKey) { _, _ in
                            needsSaving = true
                        }
                    
                    TextField("Base URL (optional)", text: $settings.openAIBaseURL)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 250)
                        .onChange(of: settings.openAIBaseURL) { _, _ in
                            needsSaving = true
                        }
                    
                    Button("Get OpenAI API Key") {
                        if let url = URL(string: "https://platform.openai.com/account/api-keys") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .buttonStyle(.link)
                    .font(.caption)
                    .help("Open OpenAI dashboard to create an API key.")
                }
                .frame(width: 250, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
