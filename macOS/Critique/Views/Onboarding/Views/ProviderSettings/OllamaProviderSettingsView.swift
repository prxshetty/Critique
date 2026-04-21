//
//  OllamaProviderSettingsView.swift
//  Critique
//
//  Created by Arya Mirsepasi on 04.11.25.
//

import SwiftUI

struct OllamaProviderSettingsView: View {
  @Bindable var settings: AppSettings

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Configure Ollama (Self-Hosted)")
        .font(.headline)
      
      Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 12) {
        GridRow {
          Text("Base URL:")
            .foregroundStyle(.secondary)
            .frame(width: 110, alignment: .trailing)
          
          TextField("http://localhost:11434", text: $settings.ollamaBaseURL)
            .textFieldStyle(.roundedBorder)
            .frame(width: 250)
        }
        
        GridRow {
          Text("Model:")
            .foregroundStyle(.secondary)
            .frame(width: 110, alignment: .trailing)
          
          TextField("Model Name (e.g. llama3)", text: $settings.ollamaModel)
            .textFieldStyle(.roundedBorder)
            .frame(width: 250)
        }
        
        GridRow {
          Text("Keep Alive:")
            .foregroundStyle(.secondary)
            .frame(width: 110, alignment: .trailing)
          
          TextField("e.g., 5m, 1h", text: $settings.ollamaKeepAlive)
            .textFieldStyle(.roundedBorder)
            .frame(width: 250)
        }

        GridRow(alignment: .top) {
          Text("Vision:")
            .foregroundStyle(.secondary)
            .frame(width: 110, alignment: .trailing)
            .padding(.top, 4)
          
          VStack(alignment: .leading, spacing: 6) {
            Picker("", selection: $settings.ollamaImageMode) {
              ForEach(OllamaImageMode.allCases) { mode in
                Text(mode.displayName).tag(mode)
              }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            
            Text("Use local OCR or Ollama's vision model for images.")
              .font(.caption2)
              .foregroundStyle(.secondary)
          }
          .frame(width: 250)
        }
        
        GridRow {
          Spacer()
          Button("Ollama Documentation") {
            if let url = URL(string: "https://ollama.ai/download") {
              NSWorkspace.shared.open(url)
            }
          }
          .buttonStyle(.link)
          .frame(width: 250, alignment: .leading)
        }
      }
    }
  }
}
