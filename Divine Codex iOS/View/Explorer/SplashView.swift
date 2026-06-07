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
    var body: some View {
        ZStack {
            Theme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Image("icon")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 400, maxHeight: 400)

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
