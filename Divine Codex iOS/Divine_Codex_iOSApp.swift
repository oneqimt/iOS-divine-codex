//
//  Divine_Codex_iOSApp.swift
//  Divine Codex iOS
//
//  Created by Dennis Miller on 5/28/26.
//

import SwiftUI
import OSLog

private let appLogger = Logger(
    subsystem: "com.divinecodex.DivineCodexiOS",
    category: "App"
)

@main
struct Divine_Codex_iOSApp: App {

    /// App-wide Sanity view model. Constructed once at launch and injected
    /// into the SwiftUI environment so any view can read its state.
    @State private var sanity: SanityViewModel

    /// App-wide Explorer view model (owns the cosmology node graph + selection).
    /// 
    /// Initialized explicitly inside `init()` using `_explorerViewModel = State(initialValue: ...)`
    /// (exactly like `sanity`). This ensures creation happens at a well-defined point during
    /// App launch (after token/client setup) and avoids any subtle differences in timing or
    /// ordering compared to a property-level default initializer. The VM loads its local
    /// hierarchy immediately so the Explorer tab has zero creation cost on first appearance.
    /// Injected via Environment; server data is merged from HomeView regardless of active tab.
    @State private var explorerViewModel: ExplorerViewModel

    init() {
        // 1. Make sure the API token is loaded into TokenManager before we
        //    build the client. `setupToken()` lives in `secret.swift`.
        setupToken()

        // 2. CDN behavior: fresh data in DEBUG, cached in RELEASE.
        #if DEBUG
        let useCdn = false
        appLogger.info("App init — DEBUG mode, useCdn=false")
        #else
        let useCdn = true
        appLogger.info("App init — RELEASE mode, useCdn=true")
        #endif

        // 3. Build the concrete Sanity client.
        let client = SanityClient(
            projectId: sanityProjectId,
            dataset: sanityDataset,
            useCdn: useCdn,
            token: TokenManager.shared.getToken()
        )

        // 4. Wrap the view models using the underscore storage (`_sanity`, `_explorerViewModel`).
        //    This is required when assigning to @State properties from `init()`.
        //    We use the same explicit `State(initialValue:)` pattern for both so that
        //    creation timing is identical and deterministic.
        _sanity = State(initialValue: SanityViewModel(client: client))
        _explorerViewModel = State(initialValue: ExplorerViewModel())
    }

    var body: some Scene {
        WindowGroup {
            // RootView gates an animated splash over a live HomeView. The splash
            // covers the launch-time Liquid Glass warmup (HomeView drives one
            // real tab transition underneath) and dismisses when warmup signals
            // completion — so the user's first tab tap is smooth.
            RootView()
                .environment(sanity)
                .environment(explorerViewModel)
                .task {
                    // Prefetch emanation data at app launch.
                    // Data is merged into the (shared) ExplorerViewModel by
                    // HomeView (which is always in the hierarchy and observes
                    // changes on sanity.emanations). This keeps ExplorerView
                    // initialization fast and ensures server nodes are available
                    // even if the user visits the Explorer tab after launch.
                    await sanity.fetchEmanations()
                }
        }
    }
}

// MARK: - Root coordinator (Splash → HomeView)

/// Shows `SplashView` over a live `HomeView` at launch. `HomeView` warms the
/// Liquid Glass transition pipeline underneath the splash and calls back when
/// done; the splash then fades away to reveal the warm UI.
private struct RootView: View {
    @State private var isWarm = false

    var body: some View {
        ZStack {
            // HomeView is alive from launch (hidden beneath the splash) so its
            // real TabBarView glass can warm up. Once warm, it fades in.
            HomeView(onWarmupComplete: {
                withAnimation(.easeInOut(duration: 0.45)) {
                    isWarm = true
                }
            })
            .opacity(isWarm ? 1 : 0)

            if !isWarm {
                SplashView()
                    .transition(.opacity)
            }
        }
    }
}
