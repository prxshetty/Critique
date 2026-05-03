import SwiftUI
import AppKit

// MARK: - App Theme

enum AppTheme: String, CaseIterable {
    case standard
    case gradient
    case glass
    case oled

    var displayName: String {
        switch self {
        case .standard: return "Standard"
        case .gradient: return "Gradient"
        case .glass:    return "Glass"
        case .oled:     return "OLED"
        }
    }
}

// MARK: - Window Background Modifier

struct WindowBackground: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    private var settings = AppSettings.shared
    let shape: AnyShape
    let themeOverride: AppTheme?

    init(shape: AnyShape, themeOverride: AppTheme? = nil) {
        self.shape = shape
        self.themeOverride = themeOverride
    }

    var currentTheme: AppTheme {
        themeOverride ?? settings.themeStyle
    }

    func body(content: Content) -> some View {
        let tokens = DesignSystem.tokens(for: currentTheme)
        
        content
            .background(
                Group {
                    switch currentTheme {
                    case .standard:
                        if colorScheme == .light {
                            Rectangle().fill(Color(NSColor.windowBackgroundColor).opacity(0.95))
                        } else {
                            Rectangle().fill(.regularMaterial)
                        }
                    case .gradient:
                        MeshLikeGradientBackground()
                    case .glass:
                        GlassmorphicBackground(stroke: shape)
                    case .oled:
                        colorScheme == .dark ? Color.black : Color.white
                    }
                }
                .clipShape(shape)
            )
            .shadow(
                color: tokens.shadowColor(colorScheme),
                radius: tokens.shadowRadius,
                x: 0,
                y: tokens.shadowYOffset
            )
    }
}

// MARK: - Gradient Background

struct MeshLikeGradientBackground: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        LinearGradient(
            colors: colorScheme == .light
                ? [Color(hex: "7c5cbf"), Color(hex: "b05090")]
                : [Color(hex: "452E6B"), Color(hex: "703F3F")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Glass Background

struct GlassmorphicBackground: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency
    var stroke: AnyShape = AnyShape(Rectangle())

    var body: some View {
        ZStack {
            if reduceTransparency {
                colorScheme == .light ? Color(.windowBackgroundColor) : Color.black
            } else {
                CustomGlassBackground(colorScheme: colorScheme, stroke: stroke)
            }
        }
    }
}

/// App-defined glass treatment used across macOS versions so the theme
/// stays visually stable instead of depending on the system Liquid Glass.
struct CustomGlassBackground: View {
    let colorScheme: ColorScheme
    var stroke: AnyShape = AnyShape(Rectangle())

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)

            Rectangle()
                .fill(
                    colorScheme == .light
                        ? Color.white.opacity(0.72)
                        : Color.white.opacity(0.08)
                )

            Rectangle()
                .fill(
                    colorScheme == .light
                        ? Color.black.opacity(0.035)
                        : Color.black.opacity(0.18)
                )

            // Use stroke + mask to simulate strokeBorder on AnyShape
            stroke
                .stroke(
                    colorScheme == .light
                        ? Color.black.opacity(0.14)
                        : Color.white.opacity(0.18),
                    lineWidth: 2.0 // Double width because half is masked out
                )
                .mask(stroke)
        }
    }
}

// MARK: - Hex Color Init

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
// MARK: - View Extension

extension View {
    func windowBackground(theme: AppTheme? = nil, shape: some Shape) -> some View {
        modifier(WindowBackground(shape: AnyShape(shape), themeOverride: theme))
    }
}
