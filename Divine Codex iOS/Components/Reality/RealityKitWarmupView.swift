//
//  RealityKitWarmupView.swift
//  Divine Codex iOS
//
//  Tiny hidden RealityView that pre-warms the renderer at app launch (mounted
//  from HomeView so it survives tab switches). Also prefetches Explorer assets.
//

import RealityKit
import SwiftUI
import UIKit

struct RealityKitWarmupView: View {

    var body: some View {
        RealityView { content in
            let mesh = MeshResource.generateSphere(radius: 0.05)
            let material = SimpleMaterial(color: .clear, isMetallic: false)
            let entity = ModelEntity(mesh: mesh, materials: [material])
            content.add(entity)
        }
        .frame(width: 2, height: 2)
        .opacity(0.01)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

enum CosmoExplorerPrefetch {

    /// Decodes the Explorer tab hero image off the critical first-paint path.
    static func warm() {
        Task { @MainActor in
            _ = UIImage(named: "monad-emanation")
        }
    }
}