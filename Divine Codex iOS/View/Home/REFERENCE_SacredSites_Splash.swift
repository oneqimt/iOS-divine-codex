//
//  REFERENCE_SacredSites_Splash.swift
//  Divine Codex iOS — REFERENCE ONLY (do not compile/ship)
//
//  Saved from a previous project (Sacred Sites) as the pattern to adapt for
//  the Divine Codex splash screen. Captured here so we don't have to re-paste
//  it each session. See IN_PROGRESS.md → "Splash Screen / Glass Warmup Plan".
//
//  KEY POINTS TO ADAPT FOR DIVINE CODEX:
//  - Divine Codex uses modern @Observable + .environment(...) (NOT @StateObject
//    / @EnvironmentObject as below). Keep the modern style.
//  - Use Theme.Colors / Theme.Fonts and the "logo" asset + the existing
//    "Ancient wisdom reawakened" tagline instead of the Sacred Sites branding.
//  - IMPORTANT: the splash must cover a *live* HomeView so the real TabBarView's
//    Liquid Glass transition pipeline can warm up underneath (see plan).
//
//  ----------------------------------------------------------------------------
//  ORIGINAL: Sacred_SitesApp.swift
//  ----------------------------------------------------------------------------
/*
import SwiftUI

@main
struct Sacred_SitesApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // Initialize the orientation manager as early as possible
    private let orientationManager = OrientationManager.shared
    // Core Data
    let persistenceController = CoreDataManager.shared

    @StateObject private var sanityViewModel = SanityViewModel()
    @StateObject private var favoritesViewModel = FavoritesViewModel()
    @StateObject private var journalViewModel = JournalViewModel()
    @StateObject private var cycleHistoryViewModel = CycleHistoryViewModel()

    @State private var initialRenderComplete = false

    init() {
        setupToken()
        // Apply orientation lock immediately
        if UIDevice.current.userInterfaceIdiom == .phone {
            orientationManager.lockToPortrait()
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(initialRenderComplete: $initialRenderComplete)
                .environmentObject(sanityViewModel)
                .environmentObject(favoritesViewModel)
                .environmentObject(journalViewModel)
                .environmentObject(orientationManager)
                .environmentObject(cycleHistoryViewModel)
                .environment(\.managedObjectContext, persistenceController.context)
                .task {
                    await favoritesViewModel.fetchFavorites()
                }
        }
    }
}

/// Thin wrapper so we can read `@Environment(\.displayScale)` and pipe it
/// into `ImageCache` without touching the deprecated `UIScreen.main`.
private struct RootView: View {
    @Binding var initialRenderComplete: Bool
    @Environment(\.displayScale) private var displayScale
    @EnvironmentObject private var orientationManager: OrientationManager
    @EnvironmentObject private var sanityViewModel: SanityViewModel
    @EnvironmentObject private var favoritesViewModel: FavoritesViewModel
    @EnvironmentObject private var journalViewModel: JournalViewModel
    @EnvironmentObject private var cyclehistoryViewModel: CycleHistoryViewModel

    var body: some View {
        ZStack {
            if !initialRenderComplete {
                AnimatedSplashView {
                    initialRenderComplete = true
                }
                .environmentObject(orientationManager)
            } else {
                MainTabView()
                    .environmentObject(orientationManager)
            }
        }
        .background(.clear)
        .background {
            // GeometryReader hidden in background so it doesn't affect
            // the layout of MainTabView or block Liquid Glass compositing.
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        configureImageCache(size: geometry.size)
                    }
                    .onChange(of: geometry.size) { _, newSize in
                        configureImageCache(size: newSize)
                    }
                    .onChange(of: displayScale) { _, _ in
                        configureImageCache(size: geometry.size)
                    }
            }
        }
    }

    private func configureImageCache(size: CGSize) {
        let maxDimension = max(size.width, size.height)
        ImageCache.shared.configureScreen(scale: displayScale, maxDimension: maxDimension)
    }
}
*/

//  ----------------------------------------------------------------------------
//  ORIGINAL: AnimatedSplashView.swift
//  ----------------------------------------------------------------------------
/*
import SwiftUI

struct AnimatedSplashView: View {
    @State private var showSubtitle = false
    @State private var showProgress = false
    let onFinished: () -> Void

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                Image("sacred-splash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.white)

                Text("Sacred Sites")
                    .font(.system(size: 42, weight: .bold, design: .serif))
                    .foregroundColor(.white)

                // Additional elements that animate in
                if showSubtitle {
                    Text("Discover the world's most sacred places")
                        .font(.system(size: 18, weight: .medium, design: .serif))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                if showProgress {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                        .padding(.top, 20)
                        .transition(.opacity)
                }
            }
        }
        .onAppear {
            // Start animations immediately
            withAnimation(.easeIn(duration: 0.4)) {
                showSubtitle = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeIn(duration: 0.4)) {
                    showProgress = true
                }
            }

            // Start data loading, not used if using local images for HomeView
            Task {
                // Can reduce this minimum time since the launch screen already showed
                try? await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds
                onFinished()
            }
        }
    }
}
*/
