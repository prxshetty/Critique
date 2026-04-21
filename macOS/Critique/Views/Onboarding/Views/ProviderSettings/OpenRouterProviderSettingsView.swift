//
//  OpenRouterProviderSettingsView.swift
//  Critique
//
//  Created by Arya Mirsepasi on 04.11.25.
//

import SwiftUI

struct OpenRouterProviderSettingsView: View {
  @Bindable var settings: AppSettings

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 12) {
        GridRow {
          Text("API Key:")
            .foregroundStyle(.secondary)
            .frame(width: 110, alignment: .trailing)
          
          SecureAPIKeyField("", text: $settings.openRouterApiKey)
            .frame(width: 250)
        }
        
        GridRow {
          Text("Model:")
            .foregroundStyle(.secondary)
            .frame(width: 110, alignment: .trailing)
          
          Picker("", selection: $settings.openRouterModel) {
            ForEach(OpenRouterModel.allCases, id: \.self) { model in
              Text(model.displayName).tag(model.rawValue)
            }
          }
          .pickerStyle(.menu)
          .labelsHidden()
          .frame(width: 250, alignment: .leading)
        }
        
        if settings.openRouterModel == OpenRouterModel.custom.rawValue {
          GridRow {
            Spacer()
            TextField("Custom Model (e.g. meta-llama/llama-3-8b)", text: $settings.openRouterCustomModel)
              .textFieldStyle(.roundedBorder)
              .frame(width: 250)
          }
        }
        
        GridRow {
          Spacer()
          Button("Get OpenRouter API Key") {
            if let url = URL(string: "https://openrouter.ai/keys") {
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
