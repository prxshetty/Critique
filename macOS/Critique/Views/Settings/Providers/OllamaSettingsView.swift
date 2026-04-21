//
//  OllamaSettingsView.swift
//  Critique
//
//  Created by Arya Mirsepasi on 04.11.25.
//

import SwiftUI
import AppKit

struct OllamaSettingsView: View {
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
                    TextField("Model Name", text: $settings.ollamaModel)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 250)
                        .onChange(of: settings.ollamaModel) { _, _ in
                            needsSaving = true
                        }
                    
                    Text("e.g., mistral, llama3")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: 250, alignment: .leading)
                }
                .frame(width: 250, alignment: .leading)
            }
            
            // Base URL Configuration
            GridRow {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Server URL:")
                        .foregroundStyle(.secondary)
                    Text("Connection")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .gridColumnAlignment(.trailing)
                .frame(width: 110, alignment: .trailing)
                
                TextField("http://localhost:11434", text: $settings.ollamaBaseURL)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 250)
                    .onChange(of: settings.ollamaBaseURL) { _, _ in
                        needsSaving = true
                    }
                .frame(width: 250, alignment: .leading)
            }
            
            // Keep Alive Configuration
            GridRow {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Keep Alive:")
                        .foregroundStyle(.secondary)
                    Text("Memory")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .gridColumnAlignment(.trailing)
                .frame(width: 110, alignment: .trailing)
                
                VStack(alignment: .leading, spacing: 4) {
                    TextField("5m", text: $settings.ollamaKeepAlive)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                        .onChange(of: settings.ollamaKeepAlive) { _, _ in
                            needsSaving = true
                        }
                    
                    Text("Duration to keep model in memory (e.g. 5m, 1h)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: 250, alignment: .leading)
                }
                .frame(width: 250, alignment: .leading)
            }
            
            // Image Recognition
            GridRow {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Vision:")
                        .foregroundStyle(.secondary)
                    Text("Features")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .gridColumnAlignment(.trailing)
                .frame(width: 110, alignment: .trailing)
                
                VStack(alignment: .leading, spacing: 8) {
                    Picker("", selection: $settings.ollamaImageMode) {
                        ForEach(OllamaImageMode.allCases) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .frame(width: 250, alignment: .leading)
                    .onChange(of: settings.ollamaImageMode) { _, _ in
                        needsSaving = true
                    }
                    
                    Text("Use local OCR or a vision LLM for screenshots.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: 250, alignment: .leading)
                        
                    HStack(spacing: 12) {
                        LinkText()
                        
                        Button("Ollama Docs") {
                            if let url = URL(string: "https://docs.ollama.com") {
                                NSWorkspace.shared.open(url)
                            }
                        }
                        .buttonStyle(.link)
                        .help("Open Ollama download and documentation page.")
                    }
                    .padding(.top, 4)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
