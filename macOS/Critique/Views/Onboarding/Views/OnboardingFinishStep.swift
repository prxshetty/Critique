//
//  OnboardingFinishStep.swift
//  Critique
//

import SwiftUI

struct OnboardingFinishStep: View {
  var body: some View {
    VStack(spacing: 24) {
      VStack(spacing: 12) {
        // Hero Logo
        Image("MenuBarIcon")
          .resizable()
          .scaledToFit()
          .frame(width: 80, height: 80)
          .padding(.top, 20)

        Text("You're all set!")
          .font(.system(size: 32, weight: .bold))
      }

      // Features List
      VStack(spacing: 12) {
        FeatureRow(
          icon: "pencil.and.outline",
          text: "Improve your writing with one shortcut"
        )
        FeatureRow(
          icon: "cursorarrow.rays",
          text: "Works in any app that supports copy & paste"
        )
        FeatureRow(
          icon: "text.justify.left",
          text: "Preserves formatting for supported apps"
        )
        FeatureRow(
          icon: "command.square",
          text: "Custom commands & per-command shortcuts"
        )
      }
      .padding(.horizontal, 4)

      // How it works card
      VStack(alignment: .leading, spacing: 10) {
        Text("How it works")
          .font(.headline)
          .foregroundStyle(.primary)

        Text(
          "Critique briefly copies your selection, sends it to your chosen AI provider (or a local model), and then pastes the result back results seamlessly."
        )
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .lineSpacing(4)
        .fixedSize(horizontal: false, vertical: true)
      }
      .padding(16)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(Color.primary.opacity(0.04))
          .overlay(
            RoundedRectangle(cornerRadius: 16)
              .stroke(Color.primary.opacity(0.08), lineWidth: 1)
          )
      )
      .padding(.horizontal, 4)

      Spacer()

      VStack(spacing: 8) {
        Text("If you like Critique, consider [starring on GitHub](https://github.com/prxshetty/Critique).")
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .accentColor(.primary)
      }
      .frame(maxWidth: .infinity, alignment: .center)
      .padding(.bottom, 20)
    }
  }
}

private struct FeatureRow: View {
  let icon: String
  let text: String

  var body: some View {
    HStack(spacing: 16) {
      Image(systemName: icon)
        .font(.title2)
        .foregroundStyle(.primary.opacity(0.8))
        .frame(width: 32, alignment: .center)

      Text(text)
        .font(.body)
        .foregroundStyle(.primary)
      
      Spacer()
    }
    .padding(14)
    .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
    .clipShape(.rect(cornerRadius: 12))
    .overlay(
        RoundedRectangle(cornerRadius: 12)
            .stroke(Color.primary.opacity(0.05), lineWidth: 1)
    )
  }
}

