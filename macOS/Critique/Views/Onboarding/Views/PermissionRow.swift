//
//  PermissionRow.swift
//  Critique
//
//  Created by Arya Mirsepasi on 04.11.25.
//

import SwiftUI

struct PermissionRow: View {
  enum Status {
    case granted
    case missing
  }

  let icon: String
  let title: String
  let status: Status
  let explanation: String
  let onPrimary: () -> Void

  var body: some View {
    HStack(alignment: .top, spacing: 16) {
      Image(systemName: icon)
        .font(.title2)
        .foregroundStyle(.primary.opacity(0.8))
        .frame(width: 28)

      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.body)
          .foregroundStyle(.primary)

        Text(explanation)
          .font(.caption)
          .foregroundStyle(.secondary)
          .fixedSize(horizontal: false, vertical: true)
      }
      
      Spacer()
      
      Toggle("", isOn: Binding<Bool>(
        get: { status == .granted },
        set: { newValue in
            if newValue && status == .missing {
               onPrimary()
            } else if !newValue && status == .granted {
                // Cannot revoke programmatically; tell them to use System Settings
                PermissionsHelper.openPrivacyPane()
            }
        }
      ))
      .toggleStyle(.switch)
      .labelsHidden()
    }
    .padding(16)
    .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
    .clipShape(.rect(cornerRadius: 12))
    .overlay(
        RoundedRectangle(cornerRadius: 12)
            .stroke(Color.primary.opacity(0.05), lineWidth: 1)
    )
    .accessibilityElement(children: .combine)
  }
}
