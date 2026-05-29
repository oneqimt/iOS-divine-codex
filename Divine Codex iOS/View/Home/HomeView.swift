///
//  HomeView.swift
//  Divine Codex iOS
//
//  Root navigation hub. Owns the selected tab and swaps the content view
//  beneath a custom Liquid Glass tab bar.
//
//  Created by Dennis Miller on 5/28/26.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedTab: MainTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background lives at the root so every tab inherits the same mood.
            Theme.Colors.background
                .ignoresSafeArea()

            // Content area — swaps based on the selected tab.
            Group {
                switch selectedTab {
                case .home:     HomeContentView()
                case .explorer: ExplorerView()
                case .search:   SearchView()
                case .settings: SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // Leave room so content isn't hidden beneath the floating tab bar.
            .safeAreaPadding(.bottom, 88)

            // The custom Liquid Glass tab bar floats above content.
            TabBarView(selectedTab: $selectedTab)
                .padding(.bottom, 8)
        }
    }
}

// MARK: - Home tab content

/// The Home tab: a full-bleed sacred image with the tagline anchored at the
/// bottom above the floating tab bar.
///
/// Layout strategy:
/// - The image uses `.scaledToFill()` + `.ignoresSafeArea()` so it covers the
///   full screen on every device and orientation. The artwork is expected to
///   bake in its own safe-zone padding so critical typography is never clipped
///   by device bezels or rounded corners.
/// - A bottom-up scrim keeps the tagline legible over bright regions of the
///   artwork.
/// - The tagline respects the safe area; the parent (`HomeView`) reserves
///   room beneath it for the floating tab bar.
private struct HomeContentView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            // Full-bleed sacred imagery, center-cropped.
            Image("logo")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .ignoresSafeArea()
                .accessibilityHidden(true)

            // Subtle scrim so the tagline stays legible over bright areas.
            LinearGradient(
                colors: [
                    .black.opacity(0.0),
                    .black.opacity(0.35),
                    .black.opacity(0.75)
                ],
                startPoint: .center,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            // Tagline anchored at the bottom of the content area.
            Text("Ancient wisdom reawakened.")
                .sacredSubtitle()
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.bottom, Theme.Spacing.lg)
                .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - MainTab

enum MainTab: CaseIterable {
    case home
    case explorer
    case search
    case settings

    var title: String {
        switch self {
        case .home:     return "Home"
        case .explorer: return "Explorer"
        case .search:   return "Search"
        case .settings: return "Settings"
        }
    }

    var iconName: String {
        switch self {
        case .home:     return "house.fill"
        case .explorer: return "sparkles"
        case .search:   return "magnifyingglass"
        case .settings: return "gear"
        }
    }
}

#Preview("iPhone Portrait") {
    HomeView()
}

#Preview("iPhone Landscape", traits: .landscapeLeft) {
    HomeView()
}

// Note: To preview on a specific device (e.g. iPad), use the device picker
// at the bottom of the Xcode Canvas. `.previewDevice(_:)` is ignored inside
// the `#Preview` macro.
#Preview("iPad") {
    HomeView()
}
