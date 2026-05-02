import SwiftUI
import ApplicationServices

@MainActor struct OnboardingView: View {
  @Bindable var appState: AppState
  @Bindable var settings = AppSettings.shared
  @Environment(\.accessibilityReduceMotion) var reduceMotion

  @State private var currentStep = 0
  @State private var isAccessibilityGranted = AXIsProcessTrusted()
  @State private var isScreenRecordingGranted = PermissionsHelper.checkScreenRecording()

  var body: some View {
    VStack(spacing: 0) {
      if currentStep == 1 {
        // --- Split Pane Layout (Step 1 - Customization) ---
        HStack(spacing: 0) {
          // Left Column (Content)
          VStack(alignment: .leading, spacing: 0) {
            
            VStack(alignment: .leading, spacing: 8) {
              Text("Customize Appearance")
                .font(.system(size: 32, weight: .bold))
            }
            .padding(.top, 28) // Space for window controls
            .padding(.bottom, 24)

            ScrollView {
              VStack(spacing: 20) {
                OnboardingCustomizationStep(appState: appState, settings: settings)
              }
              .padding(.bottom, 8)
            }

            Spacer()

          }
          .padding(.horizontal, 40)
          .padding(.vertical, 40)
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(Color(.windowBackgroundColor))

          // Right Column (Visual Sandbox / Preview)
          ZStack {
            Color(NSColor.windowBackgroundColor).opacity(0.6)
              .ignoresSafeArea()
              
            // Live Sandbox for the Popup
            OnboardingMockupView(isSuccess: false) {
                ToolbarView(
                  appState: appState,
                  closeAction: {}
                )
                .frame(width: 380, height: 180)
                .allowsHitTesting(false)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                .scaleEffect(0.85)
            }
            .scaleEffect(1.0)
          }
          .frame(width: 520)
          .overlay(
              Rectangle()
                  .frame(width: 1)
                  .foregroundStyle(Color.black.opacity(0.05)),
              alignment: .leading
          )
        }
      } else {
        // --- Full Screen Layout (Step 0 and Step 2) ---
        ScrollView {
          if currentStep == 0 {
            OnboardingWelcomeStep(
              isAccessibilityGranted: $isAccessibilityGranted,
              isScreenRecordingGranted: $isScreenRecordingGranted,
              wantsScreenshotOCR: $settings.wantsScreenshotOCR,
              onRefresh: refreshPermissionStatuses
            )
            .padding(.top, 40) // Space for window controls
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity, minHeight: 600)
          } else {
            OnboardingFinishStep()
            .padding(.top, 40) // Space for window controls
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity, minHeight: 600)
          }
        }
        .background(Color(.windowBackgroundColor))
      }

      // --- Universal Footer ---

      
      HStack {
        if currentStep > 0 {
          Button("Back") {
            withAnimation(reduceMotion ? nil : .spring()) { currentStep -= 1 }
          }
          .buttonStyle(.bordered)
          .controlSize(.large)
        }

        Spacer()

        HStack(spacing: 8) {
          ForEach(0 ..< 3, id: \.self) { index in
            Circle()
              .fill(currentStep >= index ? Color.accentColor : Color.gray.opacity(0.3))
              .frame(width: 8, height: 8)
          }
        }
        .padding(.horizontal, 20)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(currentStep + 1) of 3")

        Spacer()

        if currentStep < 2 {
          Button("Next") {
            withAnimation(reduceMotion ? nil : .spring()) { currentStep += 1 }
          }
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
          .disabled(isNextDisabled)
        } else {
          Button("Finish") {
            saveSettingsAndFinish()
          }
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
        }
      }
      .padding(20)
      .background(Color(.windowBackgroundColor))
    }
    .frame(minWidth: 950, idealWidth: 1000, maxWidth: 1100, minHeight: 600, idealHeight: 700, maxHeight: 900)
    .background(
      Rectangle()
        .fill(Color.clear)
        .windowBackground(theme: .standard, shape: Rectangle())
    )
    .onAppear {
      refreshPermissionStatuses()
    }
    .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
      refreshPermissionStatuses()
    }
  }

  private var isNextDisabled: Bool {
    if currentStep == 0 {
      return !isAccessibilityGranted || (settings.wantsScreenshotOCR && !isScreenRecordingGranted)
    } else if currentStep == 1 {
      return !isProviderConfigured
    }
    return false
  }

  private var isProviderConfigured: Bool {
    switch settings.currentProvider {
    case "gemini": return !settings.geminiApiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    case "openai": return !settings.openAIApiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    case "mistral": return !settings.mistralApiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    case "anthropic": return !settings.anthropicApiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    case "openrouter": return !settings.openRouterApiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    case "ollama": return !settings.ollamaBaseURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !settings.ollamaModel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    case "apple": return true
    case "local": return true
    default: return false
    }
  }

  private func refreshPermissionStatuses() {
    isAccessibilityGranted = AXIsProcessTrusted()
    isScreenRecordingGranted = PermissionsHelper.checkScreenRecording()
  }

  @MainActor
  private func saveSettingsAndFinish() {
    appState.saveCurrentProviderSettings()
    settings.hasCompletedOnboarding = true

    if let window = NSApplication.shared.windows.first(where: {
      $0.identifier?.rawValue == "OnboardingWindow"
    }) {
      window.close()
    }
  }
}


