//
//  SpinningCosmoOrbView.swift
//  Divine Codex iOS
//
//  Monad hero orb: looping video background (Sanity video.url) with a pulsing
//  center dot above, or a RealityKit sphere when no video is set.
//

import RealityKit
import SwiftUI

struct SpinningCosmoOrbView: View {

    let node: ExplorerNode
    var diameter: CGFloat
    var isEmphasized: Bool = true
    var showsLabel: Bool = true
    var onTap: () -> Void
    var onLongPress: () -> Void
    var onSceneReady: (() -> Void)? = nil

    @State private var sceneUpdateSubscription: EventSubscription?
    @State private var didSignalReady = false

    private let modelRadius: Float = 0.55

    private var usesVideoBackground: Bool {
        node.videoURL != nil
    }

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                orbFill
                    .frame(width: diameter, height: diameter)
                    .clipShape(Circle())
                    .allowsHitTesting(false)

                Circle()
                    .stroke(.white.opacity(isEmphasized ? 0.45 : 0.22), lineWidth: isEmphasized ? 2 : 1)
                    .frame(width: diameter, height: diameter)
                    .allowsHitTesting(false)
            }
            .frame(width: diameter, height: diameter)
            .contentShape(Circle())
            .onTapGesture(perform: onTap)
            .onLongPressGesture(minimumDuration: 0.45, perform: onLongPress)
            .shadow(
                color: nodeColor.opacity(isEmphasized ? 0.65 : 0.35),
                radius: isEmphasized ? 22 : 10
            )

            if showsLabel {
                orbLabel
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(node.name)
        .accessibilityHint("Tap to enter. Long press for details.")
    }

    // MARK: - Orb fill (video + dot, or RealityKit shell)

    @ViewBuilder
    private var orbFill: some View {
        if let videoURL = node.videoURL {
            ZStack {
                LoopingMutedVideoView(url: videoURL)
                Circle()
                    .fill(.black.opacity(0.12))
                MonadCenterPulseView(diameter: diameter * 0.11)
            }
            .onAppear { signalReady() }
        } else if CosmoRealityKitSupport.isSupported {
            realityCanvas
        } else {
            ZStack {
                Circle()
                    .fill(nodeColor.gradient)
                MonadCenterPulseView(diameter: diameter * 0.11)
            }
            .onAppear { signalReady() }
        }
    }

    // MARK: - Reality canvas (no video fallback)

    private var realityCanvas: some View {
        ZStack {
            RealityView { content in
                let orb = CosmoOrbEntityBuilder.makeOrbRoot(for: node, radius: modelRadius)
                content.add(orb)

                let camera = PerspectiveCamera()
                camera.camera.fieldOfViewInDegrees = 42
                let cameraPosition = SIMD3<Float>(0, 0, 1.65)
                camera.position = cameraPosition
                camera.look(at: .zero, from: cameraPosition, relativeTo: nil)
                content.add(camera)

                var pulsePhase: Float = 0
                sceneUpdateSubscription?.cancel()
                sceneUpdateSubscription = content.subscribe(to: SceneEvents.Update.self) { event in
                    pulsePhase += Float(event.deltaTime)
                    Self.updateCenterPulse(on: orb, phase: pulsePhase)
                    signalReadyOnce()
                }
            }
            .onDisappear {
                sceneUpdateSubscription?.cancel()
                sceneUpdateSubscription = nil
            }
        }
    }

    // MARK: - Label

    private var orbLabel: some View {
        VStack(spacing: 3) {
            if let type = node.emanationType {
                Text(type.capitalized)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.Colors.divineGold)
                    .textCase(.uppercase)
                    .tracking(0.8)
            }

            Text(node.name)
                .font(.system(size: labelFontSize, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.Colors.primaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: diameter + 40)
        }
    }

    private var labelFontSize: CGFloat {
        diameter > 100 ? 18 : (diameter > 60 ? 14 : 11)
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

    private func signalReadyOnce() {
        DispatchQueue.main.async {
            signalReady()
        }
    }

    // MARK: - Animation

    private static func updateCenterPulse(on orb: Entity, phase: Float) {
        let blend = CosmoOrbEntityBuilder.pulseBlend(phase: phase)
        let scale = CosmoOrbEntityBuilder.pulseScale(phase: phase)
        let pulseColor = CosmoOrbEntityBuilder.pulseColor(blend: blend)
        let pulseMaterial = SimpleMaterial(color: pulseColor, isMetallic: false)

        guard let dot = orb.findEntity(named: "centerPulse") as? ModelEntity else { return }
        dot.scale = SIMD3<Float>(repeating: scale)
        dot.model?.materials = [pulseMaterial]
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