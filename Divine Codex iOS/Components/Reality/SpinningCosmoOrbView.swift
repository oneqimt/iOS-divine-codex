//
//  SpinningCosmoOrbView.swift
//  Divine Codex iOS
//
//  Monad hero orb: optional looping video (Sanity video.url) or a matte SwiftUI
//  sphere with a pulsing center dot. RealityKit is reserved for future wireframe work.
//

import SwiftUI
import UIKit

struct SpinningCosmoOrbView: View {

    let node: ExplorerNode
    var diameter: CGFloat
    var isEmphasized: Bool = true
    var showsLabel: Bool = true
    var onTap: () -> Void
    var onLongPress: () -> Void
    var onSceneReady: (() -> Void)? = nil
    /// False while detail sits above the stage — restarts pulse when true again.
    var isStageVisible: Bool = true

    @State private var didSignalReady = false

    var body: some View {
        VStack(spacing: 10) {
            orbFill
                .frame(width: diameter, height: diameter)
                .clipShape(Circle())
                .contentShape(Circle())
                .onTapGesture(perform: onTap)
                .onLongPressGesture(minimumDuration: 0.45, perform: onLongPress)

            if showsLabel {
                CosmoOrbCaption(node: node, diameter: diameter, scale: .emphasis)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(node.title)
        .accessibilityHint("Tap to enter. Long press for details.")
    }

    // MARK: - Orb fill

    @ViewBuilder
    private var orbFill: some View {
        if let videoURL = node.videoURL {
            ZStack {
                LoopingMutedVideoView(url: videoURL)
                MonadCenterPulseView(
                    diameter: diameter * 0.11,
                    isAnimating: isStageVisible
                )
            }
            .allowsHitTesting(false)
            .onAppear { signalReady() }
        } else {
            ZStack {
                Circle().fill(defaultOrbGradient)
                MonadCenterPulseView(
                    diameter: diameter * 0.11,
                    isAnimating: isStageVisible
                )
            }
            .allowsHitTesting(false)
            .onAppear { signalReady() }
        }
    }
    
     // MARK: - Pulse
    /// Matte fill — no RealityKit lighting (avoids white specular arcs on the shell).
    /// Knobs to adjust color of pulsating ORB
    private var defaultOrbGradient: RadialGradient {
        RadialGradient(
            colors: [
                nodeColor.opacity(0.06),
                Theme.Colors.accent.opacity(0.11),
                Theme.Colors.background.opacity(0.62)
            ],
            center: .center,
            startRadius: 0,
            endRadius: diameter * 0.28
        )
    }

    private var nodeColor: Color {
        if let hex = node.explorer?.colorHex, let ui = colorFromHex(hex) {
            return Color(ui)
        }
        return Theme.Colors.divineGold
    }

    // MARK: - Ready signal

    private func signalReady() {
        guard !didSignalReady else { return }
        didSignalReady = true
        onSceneReady?()
    }

    private func colorFromHex(_ hex: String) -> UIColor? {
        let sanitized = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        guard Scanner(string: sanitized).scanHexInt64(&rgb) else { return nil }
        return UIColor(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}
