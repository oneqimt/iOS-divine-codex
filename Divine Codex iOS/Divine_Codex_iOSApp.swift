//
//  Divine_Codex_iOSApp.swift
//  Divine Codex iOS
//
//  Created by Dennis Miller on 5/28/26.
//

import SwiftUI

@main
struct Divine_Codex_iOSApp: App {
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
        }
    }
}
