//
//  SplashView.swift
//  Divine Codex iOS
//
//  Animated launch splash: the app icon/logo + a progress spinner. Sits over a
//  live HomeView at launch so the real TabBarView's Liquid Glass transition
//  pipeline can warm up underneath. Dismisses when the warmup signals it's
//  complete (not on a fixed timer) — see RootView.
//

import SwiftUI

struct SplashView: View {

    /// Approximate violet of the app icon's background. Tweak these RGB values
    /// (0–1) to match the icon precisely — sample the icon in an image editor
    /// and convert the hex to 0–1 components if you want an exact match.
    
    private let iconViolet = Color(red: 0.20, green: 0.10, blue: 0.29)

    var body: some View {
        ZStack {
            // Radial halo: the icon's violet concentrated behind the icon,
            // fading to the app's cosmic background at the edges so the icon
            // no longer looks pasted onto flat black.
            RadialGradient(
                colors: [iconViolet, Theme.Colors.background],
                center: .center,
                startRadius: 0,
                endRadius: 800
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                Image("app-icon-no-back")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 300, maxHeight: 300)

                ProgressView()
                    .scaleEffect(1.4)
                    .tint(Theme.Colors.divineGold)
            }
        }
    }
}

#Preview {
    SplashView()
}
