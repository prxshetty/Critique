//
//  OnboardingWelcomeStep.swift
//  Critique
//
//  Created by Arya Mirsepasi on 04.11.25.
//

import SwiftUI

import ApplicationServices
import CoreGraphics

struct OnboardingWelcomeStep: View {
  @Binding var isAccessibilityGranted: Bool
  @Binding var isScreenRecordingGranted: Bool
  @Binding var wantsScreenshotOCR: Bool
  var onRefresh: () -> Void
  
  var body: some View {
    VStack(alignment: .leading, spacing: 32) {
      VStack(alignment: .leading, spacing: 12) {
        Text("Welcome to Critique")
          .font(.system(size: 32, weight: .bold))
          .frame(maxWidth: .infinity, alignment: .leading)
        
        Text("Let's get you set up.")
          .font(.title3)
          .foregroundStyle(.secondary)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .padding(.top, 20)
      .padding(.horizontal, 24)

      // Permissions Section
      VStack(alignment: .leading, spacing: 16) {
        Text("Permissions")
          .font(.headline)
          .foregroundStyle(.primary)
          .padding(.top, 20)
          .frame(maxWidth: .infinity, alignment: .leading)

        PermissionRow(
          icon: "hand.raised.square.on.square",
          title: "Accessibility (Required)",
          status: isAccessibilityGranted ? .granted : .missing,
          explanation: "Required to simulate ⌘C/⌘V for copying your selection and pasting results back into the original app.",
          onPrimary: {
            PermissionsHelper.requestAccessibility()
            Task { @MainActor in
              try? await Task.sleep(for: .milliseconds(500))
              onRefresh()
            }
          }
        )
          
        PermissionRow(
          icon: "macwindow.badge.plus",
          title: "Screen Recording (Optional)",
          status: isScreenRecordingGranted ? .granted : .missing,
          explanation: "Allows Critique to perform OCR on screenshot snippets using the local Vision framework. Only captures explicitly triggered screen snippets.",
          onPrimary: {
            PermissionsHelper.requestScreenRecording { granted in
              isScreenRecordingGranted = granted
              if granted {
                  wantsScreenshotOCR = true
              }
            }
          }
        )
      }
      .padding(.horizontal, 24)

      Spacer()
    }
  }
}

