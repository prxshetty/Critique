//
//  AnthropicProviderSettingsView.swift
//  Critique
//
//  Created by Arya Mirsepasi on 04.11.25.
//

import SwiftUI

struct AnthropicProviderSettingsView: View {
  @Bindable var settings: AppSettings
  @State private var modelSelection: AnthropicModel = .claude45Sonnet

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      
      Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 12) {
        GridRow {
          Text("API Key:")
            .foregroundStyle(.secondary)
            .frame(width: 110, alignment: .trailing)
          
          SecureAPIKeyField("", text: $settings.anthropicApiKey)
            .frame(width: 250)
        }
        
        GridRow {
          Text("Model:")
            .foregroundStyle(.secondary)
            .frame(width: 110, alignment: .trailing)
          
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
          }
        }
        
        if modelSelection == .custom {
          GridRow {
            Spacer()
            VStack(alignment: .leading, spacing: 4) {
              TextField("Custom Model Name", text: $settings.anthropicModel)
                .textFieldStyle(.roundedBorder)
              
              Text("E.g., \(AnthropicModel.allCases.filter { $0 != .custom }.map { $0.rawValue }.joined(separator: ", "))")
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
            .frame(width: 250)
          }
        }
        
        GridRow {
          Spacer()
          Button("Get Anthropic API Key") {
            if let url = URL(string: "https://console.anthropic.com/settings/keys") {
              NSWorkspace.shared.open(url)
            }
          }
          .buttonStyle(.link)
          .frame(width: 250, alignment: .leading)
        }
      }
    }
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
