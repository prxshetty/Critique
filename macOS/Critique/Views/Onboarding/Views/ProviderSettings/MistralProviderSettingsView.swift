//
//  MistralProviderSettingsView.swift
//  Critique
//
//  Created by Arya Mirsepasi on 04.11.25.
//

import SwiftUI

struct MistralProviderSettingsView: View {
  @Bindable var settings: AppSettings

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Configure Mistral AI")
        .font(.headline)
      
      Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 12) {
        GridRow {
          Text("API Key:")
            .foregroundStyle(.secondary)
            .frame(width: 110, alignment: .trailing)
          
          SecureAPIKeyField("", text: $settings.mistralApiKey)
            .frame(width: 250)
        }
        
        GridRow {
          Text("Model:")
            .foregroundStyle(.secondary)
            .frame(width: 110, alignment: .trailing)
          
          Picker("", selection: $settings.mistralModel) {
            ForEach(MistralModel.allCases, id: \.self) { model in
              Text(model.displayName).tag(model.rawValue)
            }
          }
          .pickerStyle(.menu)
          .labelsHidden()
          .frame(width: 250, alignment: .leading)
        }
        
        GridRow {
          Spacer()
          Button("Get Mistral API Key") {
            if let url = URL(string: "https://console.mistral.ai/api-keys/") {
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
