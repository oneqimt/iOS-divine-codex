//
//  GlassWarmupView.swift
//  Divine Codex iOS
//
//  Pre-warms the Liquid Glass *transition* pipeline at app launch.
//
//  Key insight from profiling: the tab bar's glass already renders at launch,
//  so static glass isn't the cost. The one-time hitch is the FIRST animated
//  `matchedGeometryEffect` move of the glass selection capsule. Nothing at
//  launch triggers that move, so the cost lands on the user's first tab tap.
//
//  This warmup performs a real, animated tab switch on an actual (off-screen)
//  TabBarView at launch — driving the matchedGeometryEffect glass transition
//  once so its pipeline compiles before the user interacts.
//
//  Usage: place `GlassWarmupView()` once in the root hierarchy (HomeView's
//  ZStack). It is invisible, non-interactive, and removes itself after warming.
//

import SwiftUI

struct GlassWarmupView: View {
    @State private var isWarming = true
    @State private var warmupTab: MainTab = .home

    var body: some View {
        Group {
            if isWarming {
                TabBarView(selectedTab: $warmupTab)
                    .opacity(0.02)          // must actually render to compile; keep barely visible
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                    .offset(y: 8)           // nudge, not off-screen, so it isn't optimized away
                    .task {
                        // Drive a real animated transition so the glass
                        // matchedGeometryEffect move compiles.
                        try? await Task.sleep(for: .milliseconds(50))
                        for tab in MainTab.allCases {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                warmupTab = tab
                            }
                            try? await Task.sleep(for: .milliseconds(120))
                        }
                        // Done warming — remove the view.
                        try? await Task.sleep(for: .milliseconds(100))
                        isWarming = false
                    }
            }
        }
    }
}
