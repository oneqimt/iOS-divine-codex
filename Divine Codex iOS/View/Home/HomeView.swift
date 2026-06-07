///
//  HomeView.swift
//  Divine Codex
//
//  Root navigation hub. Owns the selected tab and swaps the content view
//  beneath a custom Liquid Glass tab bar.
//
//  Created by Dennis Miller on 5/28/26.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedTab: MainTab = .home
    @Environment(SanityViewModel.self) private var sanity
    @Environment(ExplorerViewModel.self) private var explorerViewModel

    /// Called once the launch-time Liquid Glass warmup has run on the real tab
    /// bar. RootView uses this to dismiss the splash. Defaults to a no-op so
    /// HomeView still works when used standalone (e.g. previews).
    var onWarmupComplete: () -> Void = {}

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
        // Keep the shared ExplorerViewModel in sync with server data.
        // HomeView is the persistent root for tab navigation, so this listener
        // is always active (unlike putting it only inside ExplorerView).
        // The initial local hierarchy is already loaded when ExplorerViewModel
        // is created at app launch.
        .onAppear {
            explorerViewModel.updateWithServerData(sanity.emanations)
        }
        .onChange(of: sanity.emanations) { _, newEmanations in
            explorerViewModel.updateWithServerData(newEmanations)
        }
        .task {
            await warmUpLiquidGlass()
            onWarmupComplete()
        }
    }

    /// Drives one real Liquid Glass tab transition on the actual tab bar so the
    /// `matchedGeometryEffect` glass-move pipeline compiles while the splash
    /// covers the screen. Returns the selection to Home when done. Because this
    /// runs on the *real* TabBarView (not an off-screen copy), the system can't
    /// optimize it away — which is why earlier off-screen warmups were flaky.
    private func warmUpLiquidGlass() async {
        // Let the first frame settle so the tab bar is on-screen.
        try? await Task.sleep(for: .milliseconds(50))

        // Animate to another tab and back to compile the glass transition.
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            selectedTab = .explorer
        }
        try? await Task.sleep(for: .milliseconds(250))

        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            selectedTab = .home
        }
        // Small settle so the return transition completes before we reveal.
        try? await Task.sleep(for: .milliseconds(250))
    }
}

// MARK: - Home tab content

/// The Home tab: a full-bleed sacred image with the tagline anchored at the
/// bottom above the floating tab bar.
///
/// Layout strategy:
/// - The image is rendered as a `.background` layer with `.ignoresSafeArea()`
///   so it centers against the **true screen bounds**, not against the
///   shrunken content area that `HomeView`'s `.safeAreaPadding(.bottom, 88)`
///   produces. This guarantees the artwork is visually centered on every
///   device.
/// - A bottom-up scrim keeps the tagline legible over bright regions.
/// - The tagline respects the safe area; the parent reserves room beneath
///   it for the floating tab bar.
private struct HomeContentView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
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

            // Tagline anchored above the floating tab bar.
            Text("Ancient wisdom reawakened")
                .sacredSubtitle()
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.bottom, 130) // Clears the floating tab bar (~88pt) + breathing room
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // The image lives in the background so it centers against the **true
        // screen**, unaffected by the parent's `.safeAreaPadding(.bottom, 88)`.
        .background {
            Image("logo")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .clipped()
                .accessibilityHidden(true)
        }
        .ignoresSafeArea()
    }
}

#Preview("iPhone Portrait") {
    HomeView()
        .environment(ExplorerViewModel())
        .environment(SanityViewModel.preview)
}

#Preview("iPhone Landscape", traits: .landscapeLeft) {
    HomeView()
        .environment(ExplorerViewModel())
        .environment(SanityViewModel.preview)
}

// Note: To preview on a specific device (e.g. iPad), use the device picker
// at the bottom of the Xcode Canvas. `.previewDevice(_:)` is ignored inside
// the `#Preview` macro.
#Preview("iPad") {
    HomeView()
        .environment(ExplorerViewModel())
        .environment(SanityViewModel.preview)
}
