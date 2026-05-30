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

        // 4. Wrap it in the view model. `_sanity` is the underlying storage
        //    for the `@State` property — required when assigning from `init`.
        _sanity = State(initialValue: SanityViewModel(client: client))
    }

    var body: some Scene {
        WindowGroup {
            // Root view for the app.
            // HomeView currently contains the main navigation (TabBar + content).
            //
            // Future consideration:
            // We may introduce a SplashView here if we need to initialize
            // the Sanity client, load initial data, or perform other async setup
            // before showing the main interface.
            HomeView()
                .environment(sanity)
                .task {
                    // First connectivity smoke test — prints results to the console.
                    // Once a real list view consumes `sanity.codices`, this `.task`
                    // can move there (or stay here for app-launch prefetch).
                   // await sanity.fetchCodices()
                }
        }
    }
}
