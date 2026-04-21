//
//  OpenAIProviderSettingsView.swift
//  Critique
//
//  Created by Arya Mirsepasi on 04.11.25.
//

import SwiftUI

struct OpenAIProviderSettingsView: View {
  @Bindable var settings: AppSettings

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Configure OpenAI (ChatGPT)")
        .font(.headline)
      
      Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 12) {
        GridRow {
          Text("API Key:")
            .foregroundStyle(.secondary)
            .frame(width: 110, alignment: .trailing)
          
          SecureAPIKeyField("", text: $settings.openAIApiKey)
            .frame(width: 250)
        }
        
        GridRow {
          Text("Base URL:")
            .foregroundStyle(.secondary)
            .frame(width: 110, alignment: .trailing)
          
          TextField("https://api.openai.com/v1", text: $settings.openAIBaseURL)
            .textFieldStyle(.roundedBorder)
            .frame(width: 250)
        }
        
        GridRow {
          Text("Model:")
            .foregroundStyle(.secondary)
            .frame(width: 110, alignment: .trailing)
          
          VStack(alignment: .leading, spacing: 4) {
            TextField("Model Name", text: $settings.openAIModel)
              .textFieldStyle(.roundedBorder)
            
            Text("E.g., \(OpenAIConfig.defaultModel), gpt-4o, gpt-4o-mini")
              .font(.caption2)
              .foregroundStyle(.secondary)
          }
          .frame(width: 250)
        }
        
        GridRow {
          Spacer()
          Button("Get OpenAI API Key") {
            if let url = URL(string: "https://platform.openai.com/account/api-keys") {
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
