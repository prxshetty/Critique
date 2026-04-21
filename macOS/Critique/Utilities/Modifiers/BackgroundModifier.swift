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
                        GlassmorphicBackground()
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

    var body: some View {
        ZStack {
            if reduceTransparency {
                colorScheme == .light ? Color(.windowBackgroundColor) : Color.black
            } else if #available(macOS 26.0, *) {
                LiquidGlassBackground()
            } else {
                LegacyGlassBackground(colorScheme: colorScheme)
            }
        }
    }
}

/// Native Liquid Glass — macOS 26.0+
@available(macOS 26.0, *)
struct LiquidGlassBackground: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Color.clear
            .glassEffect(
                .regular.tint(Color.white.opacity(colorScheme == .light ? 0.18 : 0.08)),
                in: .rect(cornerRadius: 0)
            )
    }
}

/// Fallback glass for macOS < 26.0
struct LegacyGlassBackground: View {
    let colorScheme: ColorScheme

    var body: some View {
        ZStack {
            // backdrop-filter: blur(4px) -> we map this to standard responsive material.
            Rectangle().fill(Material.ultraThin)

            // background: warm neutral frost tint
            Rectangle()
                .fill(Color.white.opacity(colorScheme == .light ? 0.18 : 0.08))

            // border: defined frosted edge
            Rectangle()
                .strokeBorder(
                    Color.white.opacity(colorScheme == .light ? 0.5 : 0.25),
                    lineWidth: 1.0
                )
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