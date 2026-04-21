//
//  OnboardingMockupView.swift
//  Critique
//

import SwiftUI

struct OnboardingMockupView<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    var isSuccess: Bool = false
    let content: Content

    init(isSuccess: Bool = false, @ViewBuilder content: () -> Content) {
        self.isSuccess = isSuccess
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // macOS Window Header
            HStack(spacing: 6) {
                Circle().fill(Color.red.opacity(0.6)).frame(width: 8, height: 8)
                Circle().fill(Color.yellow.opacity(0.6)).frame(width: 8, height: 8)
                Circle().fill(Color.green.opacity(0.6)).frame(width: 8, height: 8)
                Spacer()
                Image(systemName: "square.app.dashed")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color(NSColor.underPageBackgroundColor))
            
            // Editor Body
            VStack(alignment: .leading, spacing: 4) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isSuccess ? "The project proposal looks excellent. I have one minor suggestion regarding the timeline." : "I am writing to express my concern about the project timeline.")
                        .font(.system(size: 13, weight: .regular, design: .default))
                        .foregroundStyle(.secondary.opacity(0.9))
                        .lineSpacing(4)
                    
                    if !isSuccess {
                        Text("This is unacceptable.")
                            .font(.system(size: 13, weight: .regular, design: .default))
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.15))
                            .cornerRadius(4)
                    } else {
                        Text("Could we please adjust the phase 2 deadline?")
                            .font(.system(size: 13, weight: .medium, design: .default))
                            .foregroundStyle(Color.accentColor)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.08))
                            .cornerRadius(4)
                    }
                }
                
                // Content area (Real Popup) - Tight to text
                content
                    .scaleEffect(1.15)
                    .padding(.leading, -4)
                    .padding(.top, -2)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(NSColor.underPageBackgroundColor).opacity(0.85))
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .padding(.horizontal, 40)
    }
}

extension OnboardingMockupView where Content == EmptyView {
    init(isSuccess: Bool = false) {
        self.isSuccess = isSuccess
        self.content = EmptyView()
    }
}

