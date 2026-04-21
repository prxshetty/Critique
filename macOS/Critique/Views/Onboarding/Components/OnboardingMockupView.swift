//
//  OnboardingMockupView.swift
//  Critique
//

import SwiftUI

struct OnboardingMockupView<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var hovered = false
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
                Circle().fill(Color.red.opacity(0.6)).frame(width: 10, height: 10)
                Circle().fill(Color.yellow.opacity(0.6)).frame(width: 10, height: 10)
                Circle().fill(Color.green.opacity(0.6)).frame(width: 10, height: 10)
                Spacer()
                Image(systemName: "square.app.dashed")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(NSColor.windowBackgroundColor))
            
            // Editor Body
            VStack(alignment: .leading, spacing: 6) {
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
                        .padding(.bottom, 2)
                } else {
                    Text("Could we please adjust the phase 2 deadline?")
                        .font(.system(size: 13, weight: .medium, design: .default))
                        .foregroundStyle(Color.accentColor)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.08))
                        .cornerRadius(4)
                        .padding(.bottom, 2)
                }
                
                // Content area (Real Popup or Mockup)
                content
                    .scaleEffect(1.1)
                    .padding(.leading, -8)
                    .padding(.top, -4)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(NSColor.textBackgroundColor))
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.12), radius: 15, y: 8)
        .padding(.horizontal, 32)
        .rotation3DEffect(.degrees(hovered ? 1.5 : -1.5), axis: (x: 1, y: -0.5, z: 0))
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                hovered.toggle()
            }
        }
    }
}

extension OnboardingMockupView where Content == EmptyView {
    init(isSuccess: Bool = false) {
        self.isSuccess = isSuccess
        self.content = EmptyView()
    }
}

struct StaticOnboardingMockup: View {
    var isSuccess: Bool = false
    var body: some View {
        HStack(spacing: 0) {
            Text("More polite")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.primary)
            
            Spacer()
            
            // Tone Badge
            HStack(spacing: 4) {
                Text("Polite")
                    .font(.system(size: 11, weight: .semibold))
                Image(systemName: "chevron.down")
                    .font(.system(size: 8))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(Color.secondary.opacity(0.1)))
            .padding(.trailing, 8)
            
            // Submit button
            ZStack {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 20, height: 20)
                Image(systemName: "arrow.up")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 34)
        .background(
            Capsule()
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                .overlay(
                    Capsule()
                        .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                )
        )
    }
}
