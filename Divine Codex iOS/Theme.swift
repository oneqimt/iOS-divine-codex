//
//  Theme.swift
//  Divine Codex iOS
//
//  The single source of truth for the app's visual language.
//  Think of this as your CSS: colors, typography, spacing, and reusable
//  "classes" (ViewModifiers + ButtonStyles) live here so views stay clean.
//
//  Created by Dennis Miller on 5/29/26.
//

import SwiftUI

// MARK: - Theme namespace

enum Theme {

    // MARK: Colors
    // For colors that we want to vary by light/dark mode, define them as Color Sets
    // in Assets.xcassets and reference them with `Color("Name", bundle: .main)`.
    enum Colors {
        /// Deep cosmic background — the "void" behind the Pleroma.
        static let background = Color(red: 0.03, green: 0.03, blue: 0.06)

        /// Primary readable text on dark backgrounds.
        static let primaryText = Color.white

        /// Softer text. Note: we use a fixed opacity rather than `.secondary`
        /// because `.secondary` is tuned for material backgrounds and can
        /// disappear on pure black.
        static let secondaryText = Color.white.opacity(0.72)

        /// Quiet captions / hints.
        static let tertiaryText = Color.white.opacity(0.5)

        /// Brand accent — Sophia / sacred glow.
        static let accent = Color.indigo
        
        static let black = Color.black

        /// Warm divine highlight, used sparingly.
        static let divineGold = Color(red: 0.93, green: 0.78, blue: 0.43)
    }

    // MARK: Typography
    enum Fonts {
        static let heroTitle = Font.largeTitle.weight(.light)
        static let sectionHeader = Font.headline
        static let subtitle = Font.title3
        static let body = Font.body
        static let caption = Font.caption2
    }

    // MARK: Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 12
        static let md: CGFloat = 20
        static let lg: CGFloat = 32
        static let xl: CGFloat = 40
    }

    // MARK: Radii
    enum Radius {
        static let small: CGFloat = 12
        static let medium: CGFloat = 20
        static let large: CGFloat = 28
    }

    // MARK: - Cards & Floating Overlays
    /// Sizing guidance for cards that appear as 2D overlays on the 3D scene
    /// (e.g. the expanded NodeDetailView that "becomes" a selected node).
    /// Using theme constants keeps the numbers out of individual views.
    enum Cards {
        /// For NodeDetailView when rendered as a floating 3D-scene label/card.
        /// The wide max allows longer descriptions (especially on iPad) without
        /// excessive wrapping, while still keeping the card from dominating the view.
        static let explorerDetailMinWidth: CGFloat = 100
        static let explorerDetailMaxWidth: CGFloat = 550
    }
}

// MARK: - Reusable "CSS class" modifiers

/// A sacred page background. Use as the root of any top-level screen.
struct SacredBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Theme.Colors.background
                .ignoresSafeArea()
            content
        }
    }
}

/// The look used for hero titles ("The Divine Codex", "The Cosmology Explorer").
struct SacredHeadingStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Theme.Fonts.heroTitle)
            .foregroundStyle(Theme.Colors.primaryText)
            .multilineTextAlignment(.center)
    }
}

/// Subtitle / supporting copy under a hero title.
struct SacredSubtitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Theme.Fonts.subtitle)
            .foregroundStyle(Theme.Colors.secondaryText)
            .multilineTextAlignment(.center)
    }
}

extension View {
    /// Apply the sacred page background.
    func sacredBackground() -> some View { modifier(SacredBackground()) }

    /// Style a `Text` as a sacred heading.
    func sacredHeading() -> some View { modifier(SacredHeadingStyle()) }

    /// Style a `Text` as a sacred subtitle.
    func sacredSubtitle() -> some View { modifier(SacredSubtitleStyle()) }
}

// MARK: - Liquid Glass button style

/// A prominent "ritual" call-to-action that uses Liquid Glass.
/// Falls back gracefully on systems before Liquid Glass shipped.
struct PleromaButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Fonts.sectionHeader)
            .foregroundStyle(Theme.Colors.primaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, Theme.Spacing.md)
            // Non-interactive glass — `.interactive()` can swallow Button taps.
            .glassEffect(
                .regular.tint(Theme.Colors.black.opacity(0.88)),
                in: .capsule
            )
            .contentShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
