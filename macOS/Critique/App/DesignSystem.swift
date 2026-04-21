import SwiftUI

/// Centralized Design System defining "CSS-like" visual tokens for the app.
/// Frontend developers can adjust constraints, colors, and shadows safely here.
struct DesignSystem {
    // MARK: - Sizing & Spacing Tokens
    static let iconSize: CGFloat = 13
    static let buttonSize: CGFloat = 26
    static let pillHeight: CGFloat = 38
    
    static let paddingSmall: CGFloat = 4
    static let paddingMedium: CGFloat = 8
    
    static let buttonCornerRadius: CGFloat = 8
    static let pillCornerRadius: CGFloat = 100 // Fully rounded for capsules
    
    // MARK: - Typography
    static let iconFont = Font.system(size: iconSize, weight: .medium)
    static let chevronFont = Font.system(size: 7).bold()
    static let buttonIconFont = Font.system(size: 11).bold()
    static let bodyFont = Font.system(size: 13, weight: .regular)
    
    // MARK: - Theme Extracted Tokens
    struct ThemeTokens {
        let shadowRadius: CGFloat
        let shadowYOffset: CGFloat
        let shadowColor: (ColorScheme) -> Color
        let borderColor: (ColorScheme) -> Color
    }

    /// Fetches the appropriate layout tokens based on the current theme style.
    static func tokens(for theme: AppTheme) -> ThemeTokens {
        switch theme {
        case .standard:
            return ThemeTokens(
                shadowRadius: 10,
                shadowYOffset: 4,
                shadowColor: { scheme in Color.black.opacity(scheme == .light ? 0.1 : 0.3) },
                borderColor: { scheme in Color.white.opacity(scheme == .light ? 0.3 : 0.1) }
            )
        case .glass:
            return ThemeTokens(
                shadowRadius: 40,
                shadowYOffset: 8,
                shadowColor: { scheme in Color.black.opacity(scheme == .light ? 0.15 : 0.4) },
                borderColor: { scheme in Color.white.opacity(scheme == .light ? 0.3 : 0.15) }
            )
        case .gradient:
            return ThemeTokens(
                shadowRadius: 32,
                shadowYOffset: 8,
                shadowColor: { scheme in Color.black.opacity(scheme == .light ? 0.2 : 0.4) },
                borderColor: { scheme in Color.white.opacity(scheme == .light ? 0.3 : 0.15) }
            )
        case .oled:
            return ThemeTokens(
                shadowRadius: 0,
                shadowYOffset: 0,
                shadowColor: { _ in Color.clear },
                borderColor: { _ in Color.white.opacity(0.2) }
            )
        }
    }
}
