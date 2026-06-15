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
    @State private var showFrequenciesLibrary = false
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

            // Content area — ExplorerView stays mounted (hidden) so revisiting the
            // tab does not pay first-layout / image-decode cost again.
            ZStack {
                if selectedTab == .home {
                    HomeContentView {
                        showFrequenciesLibrary = true
                    }
                }
                if selectedTab == .search {
                    SearchView()
                }
                if selectedTab == .settings {
                    SettingsView()
                }

                ExplorerView()
                    .opacity(selectedTab == .explorer ? 1 : 0)
                    .allowsHitTesting(selectedTab == .explorer)
                    .accessibilityHidden(selectedTab != .explorer)
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
        .overlay {
            if CosmoRealityKitSupport.isSupported {
                RealityKitWarmupView()
            }
        }
        .onAppear {
            explorerViewModel.updateWithServerData(sanity.emanations)
            CosmoExplorerPrefetch.warm()
        }
        .onChange(of: sanity.emanations) { _, newEmanations in
            explorerViewModel.updateWithServerData(newEmanations)
        }
        .task {
            await warmUpLiquidGlass()
            onWarmupComplete()
        }
        .fullScreenCover(isPresented: $showFrequenciesLibrary) {
            FrequenciesLibraryView()
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
        // Dwell on Explorer so RealityKit + ExplorerView compile under the splash.
        try? await Task.sleep(for: .milliseconds(450))

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
    @Environment(SacredFrequenciesViewModel.self) private var frequenciesVM
    @Environment(SanityViewModel.self) private var sanity

    var onSacredFrequenciesTap: () -> Void

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

            VStack(spacing: Theme.Spacing.md) {
                Button(action: onSacredFrequenciesTap) {
                    Label {
                        VStack(spacing: 2) {
                            Text("Sacred Frequencies")
                            if !frequenciesVM.favoriteIds.isEmpty {
                                Text("\(frequenciesVM.favoriteIds.count) saved")
                                    .font(.caption)
                                    .foregroundStyle(Theme.Colors.secondaryText)
                            } else if !sanity.frequencies.isEmpty {
                                Text("\(sanity.frequencies.count) to explore")
                                    .font(.caption)
                                    .foregroundStyle(Theme.Colors.secondaryText)
                            }
                        }
                    } icon: {
                        Image(systemName: "waveform.circle.fill")
                    }
                }
                .buttonStyle(PleromaButtonStyle())
                .padding(.horizontal, Theme.Spacing.lg)

                Text("Ancient wisdom reawakened")
                    .sacredSubtitle()
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.bottom, 130)
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
        .environment(SacredFrequenciesViewModel())
}

#Preview("iPhone Landscape", traits: .landscapeLeft) {
    HomeView()
        .environment(ExplorerViewModel())
        .environment(SanityViewModel.preview)
        .environment(SacredFrequenciesViewModel())
}

// Note: To preview on a specific device (e.g. iPad), use the device picker
// at the bottom of the Xcode Canvas. `.previewDevice(_:)` is ignored inside
// the `#Preview` macro.
#Preview("iPad") {
    HomeView()
        .environment(ExplorerViewModel())
        .environment(SanityViewModel.preview)
        .environment(SacredFrequenciesViewModel())
}
