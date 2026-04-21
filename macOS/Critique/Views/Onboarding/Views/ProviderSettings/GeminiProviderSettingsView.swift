//
//  GeminiProviderSettingsView.swift
//  Critique
//
//  Created by Arya Mirsepasi on 04.11.25.
//

import SwiftUI

struct GeminiProviderSettingsView: View {
  @Bindable var settings: AppSettings

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 12) {
        GridRow {
          Text("API Key:")
            .foregroundStyle(.secondary)
            .frame(width: 110, alignment: .trailing)
          
          SecureAPIKeyField("", text: $settings.geminiApiKey)
            .frame(width: 250)
        }
        
        GridRow {
          Text("Model:")
            .foregroundStyle(.secondary)
            .frame(width: 110, alignment: .trailing)
          
          Picker("", selection: $settings.geminiModel) {
            ForEach(GeminiModel.allCases, id: \.self) { model in
              Text(model.displayName).tag(model)
            }
          }
          .pickerStyle(.menu)
          .labelsHidden()
          .frame(width: 250, alignment: .leading)
        }
        
        if settings.geminiModel == .custom {
          GridRow {
            Spacer()
            TextField("Custom Model Name", text: $settings.geminiCustomModel)
              .textFieldStyle(.roundedBorder)
              .frame(width: 250)
          }
        }
        
        GridRow {
          Spacer()
          Button("Get Gemini API Key") {
            if let url = URL(string: "https://aistudio.google.com/app/apikey") {
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
