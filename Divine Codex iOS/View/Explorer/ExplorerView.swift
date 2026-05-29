//
//  ExplorerView.swift
//  Divine Codex iOS
//
//  Created by Dennis Miller on 5/28/26.
//

import SwiftUI

/// Intermediate view shown when the user selects the Explorer tab.
///
/// Purpose:
/// - Set the mood and context before entering the immersive RealityKit experience.
/// - Provide information about what the Cosmology Explorer is and how to interact with it.
/// - Act as a transitional "cover" between the main app and the full-screen 3D scene.
///
/// Note: The background is intentionally NOT set here. `HomeView` owns the
/// sacred backdrop so all tabs share the same mood. When `ExplorerView` is
/// presented standalone (e.g. previews), wrap it with `.sacredBackground()`.
///
/// From this view, the actual CosmologyScene is presented via `.fullScreenCover`.
struct ExplorerView: View {

    @State private var showCosmologyScene = false

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            // Hero / Logo area
            VStack(spacing: Theme.Spacing.md) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 180)
                    .padding(.horizontal, Theme.Spacing.xl)

                Text("The Cosmology Explorer")
                    .sacredHeading()

                Text("A living journey through the divine hierarchy")
                    .sacredSubtitle()
                    .padding(.horizontal)
            }

            // Instructional / mood-setting content
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                Text("What to Expect")
                    .font(Theme.Fonts.sectionHeader)
                    .foregroundStyle(Theme.Colors.primaryText)

                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Label("Navigate the Aeons with intuitive gestures",
                          systemImage: "hand.tap")
                    Label("Discover the 24 Invisibles and their divine pairings",
                          systemImage: "sparkles")
                    Label("Witness Sophia’s sacred journey of descent and return",
                          systemImage: "arrow.up.arrow.down")
                }
                .font(Theme.Fonts.body)
                .foregroundStyle(Theme.Colors.secondaryText)
            }
            .padding(.horizontal, Theme.Spacing.lg)

            Spacer()

            // Launch button — Liquid Glass call to action
            Button {
                showCosmologyScene = true
            } label: {
                Text("Enter the Pleroma")
            }
            .buttonStyle(PleromaButtonStyle())
            .padding(.horizontal, Theme.Spacing.xl)
        }
        .padding(.top, Theme.Spacing.lg)
        .fullScreenCover(isPresented: $showCosmologyScene) {
            CosmoScene()
                .onDisappear {
                    // Good place for any cleanup or state reset
                    // when leaving the immersive experience.
                }
        }
    }
}

#Preview {
    ExplorerView()
        .sacredBackground()
}
