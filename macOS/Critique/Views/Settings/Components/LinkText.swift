//
//  LinkText.swift
//  Critique
//
//  Created by Arya Mirsepasi on 04.11.25.
//

import SwiftUI

struct LinkText: View {
    private static let githubURL = URL(string: "https://github.com/theJayTea/Critique?tab=readme-ov-file#-optional-ollama-local-llm-instructions")!

    var body: some View {
        HStack(spacing: 4) {
            Text("Local LLMs: use the instructions on")
                .font(.caption)
                .foregroundStyle(.secondary)
            Link("GitHub Page.", destination: Self.githubURL)
                .font(.caption)
        }
    }
}
