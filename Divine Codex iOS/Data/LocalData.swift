//
//  LocalData.swift
//  Divine Codex iOS
//
//  Temporary mock data for Cosmology Explorer development.
//
//  This file provides a small, self-contained slice of the cosmology
//  hierarchy so we can build and iterate on the scene graph, selection,
//  camera behavior, and pointing overlay without requiring a live
//  Sanity connection.
//
//  IMPORTANT:
//  - This is scaffolding only. It will be replaced or heavily evolved
//    once we define the real node model and data loading strategy.
//  - The structure here is intentionally pragmatic rather than final.
//  - We can load this data as native Swift for now, or convert it to
//    JSON loading later if that proves useful for iteration.
//
//  Created for early architecture exploration.

import Foundation
import simd

// Note: ExplorerVisuals now lives in Model/ExplorerVisuals.swift as the
// single source of truth for scene visualization data (used by both local
// models and Sanity-backed content).

// MARK: - Temporary Mock Node

/// A lightweight representation of a node in the cosmology graph.
///
/// This is **not** the final "common node model". It exists only to let us
/// start building the two-layer graph (logical + RealityKit visual) and
/// the selection/overlay machinery.
///
/// As we progress, this will likely be replaced by a more considered
/// domain model, potentially behind UseCase/Intent boundaries as discussed.
struct MockCosmicNode: Identifiable, Sendable, Hashable {
    let id: String
    let name: String
    let nodeType: NodeType

    /// Short, contemplative description suitable for an overlay.
    let shortDescription: String?

    /// Parent relationship for building the logical tree.
    /// The root (Monad) has `nil`.
    let parentId: String?

    /// Visualization hints that can drive RealityKit entity creation.
    let explorer: ExplorerVisuals?

    enum NodeType: String, Sendable, Hashable {
        case monad
        case conceptualGroup   // e.g. Pleroma as a framing layer
        case emanation
        case syzygyPair
    }
}

// MARK: - Local Cosmology Seed Data

enum LocalCosmology {

    /// The complete small set of mock nodes for early development.
    ///
    /// Hierarchy (simplified):
    /// - Monad (local root)
    ///   - Pleroma (conceptual grouping layer)
    ///     - Several of the 24 Invisibles (mix of individual emanations and syzygies)
    static let nodes: [MockCosmicNode] = [
        // MARK: The Monad — Local Root
        MockCosmicNode(
            id: "monad",
            name: "The Monad",
            nodeType: .monad,
            shortDescription: "The Ineffable Source. The One beyond all names and forms. The Divine Spark within each soul is a living fractal of this primordial unity.",
            parentId: nil,
            explorer: ExplorerVisuals(
                layerOrder: 0,
                position: SIMD3<Float>(0, 12, 0),
                colorHex: "#F5E8C7",
                geometryHint: "light",
                scale: 1.8
            )
        ),

        // MARK: Pleroma — Conceptual Grouping Layer
        MockCosmicNode(
            id: "pleroma",
            name: "The Pleroma",
            nodeType: .conceptualGroup,
            shortDescription: "The Fullness. The divine realm of perfect unity and emanation, containing the 24 Invisibles in their eternal syzygies.",
            parentId: "monad",
            explorer: ExplorerVisuals(
                layerOrder: 10,
                position: SIMD3<Float>(0, 6, 0),
                colorHex: "#C9A227",
                geometryHint: "sphere",
                scale: 2.2
            )
        ),

        // MARK: 24 Invisibles — Selected Emanations & Syzygies
        // A small, representative set for early scene work.

        // Barbelo (often paired with the Monad / The One)
        MockCosmicNode(
            id: "barbelo",
            name: "Barbelo",
            nodeType: .emanation,
            shortDescription: "The first emanation of the Monad. The Womb of the All, the Mother of the Aeons, pure thought and foreknowledge.",
            parentId: "pleroma",
            explorer: ExplorerVisuals(
                layerOrder: 20,
                position: SIMD3<Float>(-2.5, 3.5, 0),
                colorHex: "#A78BFA",
                geometryHint: "sphere",
                scale: 1.1
            )
        ),

        // Autogenes (Self-Generated, often paired with Barbelo)
        MockCosmicNode(
            id: "autogenes",
            name: "Autogenes",
            nodeType: .emanation,
            shortDescription: "The Self-Generated One. The divine mind that arises from Barbelo, containing the archetypes of all that will come forth.",
            parentId: "pleroma",
            explorer: ExplorerVisuals(
                layerOrder: 21,
                position: SIMD3<Float>(2.5, 3.5, 0),
                colorHex: "#FBBF24",
                geometryHint: "octahedron",
                scale: 1.0
            )
        ),

        // Sophia (one of the 24 Invisibles, central to the myth)
        MockCosmicNode(
            id: "sophia",
            name: "Sophia",
            nodeType: .emanation,
            shortDescription: "Divine Wisdom. The lowest of the 24 Invisibles who, in her longing, descended and brought the Divine Spark into the lower realms.",
            parentId: "pleroma",
            explorer: ExplorerVisuals(
                layerOrder: 30,
                position: SIMD3<Float>(-4.0, 0.5, -1.5),
                colorHex: "#C026D3",
                geometryHint: "sphere",
                scale: 1.0
            )
        ),

        // Christos (her syzygy / counterpart in many traditions)
        MockCosmicNode(
            id: "christos",
            name: "Christos",
            nodeType: .emanation,
            shortDescription: "The Anointed. The revealer who descends to awaken the forgotten Spark and guide the ascent of Sophia and all souls.",
            parentId: "pleroma",
            explorer: ExplorerVisuals(
                layerOrder: 31,
                position: SIMD3<Float>(4.0, 0.5, -1.5),
                colorHex: "#60A5FA",
                geometryHint: "icosahedron",
                scale: 1.0
            )
        ),

        // Additional Invisibles for density testing (pairs)
        MockCosmicNode(
            id: "harmozel",
            name: "Harmozel",
            nodeType: .emanation,
            shortDescription: "One of the four great luminaries that stand with Autogenes. Grace and truth dwell with him.",
            parentId: "pleroma",
            explorer: ExplorerVisuals(
                layerOrder: 25,
                position: SIMD3<Float>(-1.8, 2.0, 3.0),
                colorHex: "#34D399",
                geometryHint: "torus",
                scale: 0.85
            )
        ),

        MockCosmicNode(
            id: "oroiael",
            name: "Oroiael",
            nodeType: .emanation,
            shortDescription: "The second luminary. Perception and memory abide with him in the Pleroma.",
            parentId: "pleroma",
            explorer: ExplorerVisuals(
                layerOrder: 26,
                position: SIMD3<Float>(1.8, 2.0, 3.0),
                colorHex: "#F472B6",
                geometryHint: "torus",
                scale: 0.85
            )
        )
    ]

    /// Returns the root node (The Monad) for convenience when building the scene.
    static var monad: MockCosmicNode? {
        nodes.first { $0.id == "monad" }
    }

    /// Returns all nodes that are direct or indirect children of the given parentId.
    static func children(of parentId: String) -> [MockCosmicNode] {
        nodes.filter { $0.parentId == parentId }
    }

    /// Simple lookup by id.
    static func node(id: String) -> MockCosmicNode? {
        nodes.first { $0.id == id }
    }
}
