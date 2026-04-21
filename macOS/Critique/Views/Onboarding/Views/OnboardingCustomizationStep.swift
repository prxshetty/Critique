//
//  OnboardingCustomizationStep.swift
//  Critique
//
//  Created by Arya Mirsepasi on 04.11.25.
//

import SwiftUI
import KeyboardShortcuts

struct OnboardingCustomizationStep: View {
  @Bindable var appState: AppState
  @Bindable var settings: AppSettings

  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      // Activation
      VStack(alignment: .leading, spacing: 16) {
        Text("Activation")
          .font(.headline)
        
        Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 12) {
          GridRow {
            Text("Shortcut:")
              .foregroundStyle(.secondary)
              .frame(width: 110, alignment: .trailing)
            
            KeyboardShortcuts.Recorder(for: .showPopup)
          }
        }
      }

      Divider()
      
      // Appearance
      VStack(alignment: .leading, spacing: 16) {
        Text("Appearance")
          .font(.headline)
            
        Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 12) {
          GridRow {
            Text("Theme:")
              .foregroundStyle(.secondary)
              .frame(width: 110, alignment: .trailing)
            
            Picker("", selection: $settings.themeStyle) {
              ForEach(AppTheme.allCases, id: \.self) { theme in
                Text(theme.displayName).tag(theme)
              }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(width: 250, alignment: .leading)
          }
        }
      }

      Divider()
      
      // AI Provider
      VStack(alignment: .leading, spacing: 16) {
        Text("AI Writing Model")
          .font(.headline)

        Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 12) {
          GridRow {
            Text("Provider:")
              .foregroundStyle(.secondary)
              .frame(width: 110, alignment: .trailing)
            
            Picker("", selection: $settings.currentProvider) {
              if settings.isAppleIntelligenceSupported {
                Text("Apple Intelligence").tag("apple")
              }
              if LocalModelProvider.isAppleSilicon {
                Text("Local LLM").tag("local")
              }
              Text("Gemini AI").tag("gemini")
              Text("OpenAI").tag("openai")
              Text("Anthropic").tag("anthropic")
              Text("Mistral AI").tag("mistral")
              Text("Ollama").tag("ollama")
              Text("OpenRouter").tag("openrouter")
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(width: 250, alignment: .leading)
          }
        }
        
        ProviderSettingsContainerView(settings: settings, appState: appState)
          .padding(.top, 4)
      }

      Spacer()
    }
    .padding(.top, 8)
  }
}
