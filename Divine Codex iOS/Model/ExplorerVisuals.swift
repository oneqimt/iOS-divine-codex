//
//  ExplorerVisuals.swift
//  Divine Codex iOS
//
//  Visualization configuration for placing and rendering entities
//  in the RealityKit Cosmology Explorer scene.
//
//  Used by both local models (Monad, Aeon) and content coming from Sanity
//  (DivineCodex / emanation documents that have explorer data).
//

import Foundation
import simd

/// Configuration that drives how a cosmic entity appears and is positioned
/// in the 3D RealityKit scene.
struct ExplorerVisuals: Sendable, Equatable, Hashable {
    /// Z-order / rendering layer. Lower numbers render "higher" in the cosmos.
    let layerOrder: Int

    /// World position in the scene.
    let position: SIMD3<Float>?

    /// Hex color for the entity (e.g. "#F5E8C7").
    let colorHex: String?

    /// Hint for what primitive or shape to generate in RealityKit.
    /// Common values: "light", "sphere", "octahedron", "icosahedron", "torus"
    let geometryHint: String?

    /// Scale multiplier for the entity.
    let scale: Float?

    /// Convenience accessor.
    var worldPosition: SIMD3<Float> {
        position ?? .zero
    }
}
