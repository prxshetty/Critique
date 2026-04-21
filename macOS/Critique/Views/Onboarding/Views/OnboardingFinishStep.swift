//
//  OnboardingFinishStep.swift
//  Critique
//

import SwiftUI

struct OnboardingFinishStep: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 48) {
      // Header Section
      VStack(alignment: .leading, spacing: 16) {
        Text("You're all set!")
          .font(.system(size: 36, weight: .bold))
        
        Text("Critique works by briefly copying your selection, enhancing it via AI, and pasting the results back seamlessly into your original app.")
          .font(.title3)
          .foregroundStyle(.secondary)
          .lineSpacing(6)
          .fixedSize(horizontal: false, vertical: true)
      }
      .padding(.top, 20)

      // Features Grid
      VStack(alignment: .leading, spacing: 24) {
        Text("Key Features")
          .font(.headline)
          .foregroundStyle(.primary)

        LazyVGrid(columns: [
          GridItem(.flexible(), spacing: 32, alignment: .topLeading),
          GridItem(.flexible(), spacing: 32, alignment: .topLeading)
        ], spacing: 32) {
          FeatureItem(
            icon: "pencil.and.outline",
            text: "Improve writing with one shortcut"
          )
          FeatureItem(
            icon: "cursorarrow.rays",
            text: "Works in any app system-wide"
          )
          FeatureItem(
            icon: "text.justify.left",
            text: "Preserves original formatting"
          )
          FeatureItem(
            icon: "command.square",
            text: "Custom commands & shortcuts"
          )
        }
      }

      Spacer()

      // Footer
      VStack(alignment: .leading, spacing: 12) {
        Divider()
          .padding(.bottom, 8)
        
        HStack(spacing: 12) {
          Image("MenuBarIcon")
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
          
          Text("If you like Critique, consider [starring on GitHub](https://github.com/prxshetty/Critique).")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .accentColor(.primary)
        }
      }
      .padding(.bottom, 20)
    }
    .padding(.horizontal, 24)
  }
}

private struct FeatureItem: View {
  let icon: String
  let text: String

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      Image(systemName: icon)
        .font(.system(size: 20))
        .foregroundStyle(.primary.opacity(0.8))
        .frame(width: 24, alignment: .center)

      Text(text)
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .lineLimit(2)
        .fixedSize(horizontal: false, vertical: true)
    }
  }
}

