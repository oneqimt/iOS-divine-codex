//
//  RealityKitWarmupView.swift
//  Divine Codex iOS
//
//  Tiny off-screen RealityView that pre-warms the renderer while the user reads
//  ExplorerView, reducing first-open hitch for the immersive scene.
//

import RealityKit
import SwiftUI

struct RealityKitWarmupView: View {

    var body: some View {
        RealityView { content in
            let mesh = MeshResource.generateSphere(radius: 0.01)
            let material = SimpleMaterial(color: .clear, isMetallic: false)
            let entity = ModelEntity(mesh: mesh, materials: [material])
            content.add(entity)
        }
        .frame(width: 1, height: 1)
        .opacity(0.001)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}