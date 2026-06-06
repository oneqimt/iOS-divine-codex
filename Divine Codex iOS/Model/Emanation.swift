//
//  Emanation.swift
//  Divine Codex iOS
//
//  The cosmological node model. `emanation` is the spine of the data layer
//  (see IN_PROGRESS.md, "Sanity Schema – Current Implementation" / AUTHORITATIVE):
//  a self-referencing node tree (parent / consort) that both drives the 3D
//  RealityKit scene AND carries its own detail content.
//
//  These are pure value types and are safe to share across concurrency
//  domains. The top-level `Emanation`'s `Codable` conformance is declared in a
//  `nonisolated` extension so callers in any isolation domain (including
//  `@MainActor` view models) can use it to satisfy the `T: Decodable & Sendable`
//  generic on `SanityClient.fetch(query:as:)`.
//
//  Created by Dennis Miller on 6/6/26.
//

import Foundation
import simd

// MARK: - Emanation

/// A single cosmological node (Monad, Pleroma, Aeon).
///
/// The GROQ query flattens references into id strings (`parentId`, `consortId`)
/// and projects `emanationType->name` as `type`. The node tree is reassembled
/// in Swift from these ids.
struct Emanation: Identifiable, Sendable, Equatable, Hashable {
    let id: String
    let name: String?
    let slug: String?
    let gender: Gender?
    /// Traditional sequence among siblings (the 12 syzygies). Distinct from
    /// `explorer.layerOrder` (z-depth).
    let order: Int?
    /// The `emanationType` name: "Monad", "Pleroma", or "Aeon".
    let type: String?
    /// Reference id of the parent node (hierarchy backbone). `nil` for the root.
    let parentId: String?
    /// Reference id of the consort/syzygy partner. Surfaced as "Syzygy" in app.
    let consortId: String?
    /// Visualization data for the RealityKit scene.
    let explorer: Explorer?
    let shortDescription: String?
    /// Portable Text long-form detail. Reuses the same block model as before.
    let description: [PortableTextBlock]?
    /// Detail-view images (caption + alt).
    let media: [SanityMedia]?
    /// Optional externally-hosted video (HLS/MP4) for the detail view.
    let video: Video?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case slug
        case gender
        case order
        case type
        case parentId
        case consortId
        case explorer
        case shortDescription
        case description
        case media
        case video
    }
}

// MARK: - Gender

/// Masculine / feminine / neutral / pair (used for syzygies).
enum Gender: String, Codable, Sendable, Equatable, Hashable {
    case masculine
    case feminine
    case neutral
    case pair
}

// MARK: - Explorer

/// RealityKit placement + styling for a node. Maps onto the scene:
/// `position{x,y,z}` → `SIMD3<Float>`, `color` hex → `UIColor`,
/// `geometryHint` → `MeshResource`.
struct Explorer: Codable, Sendable, Equatable, Hashable {
    /// Z-depth / rendering order in the layered scene.
    let layerOrder: Int?
    let position: Position?
    /// Hex color string, e.g. "#C9A227".
    let color: String?
    let scale: Double?
    let isVisibleByDefault: Bool?
    /// "sphere" | "torus" | "octahedron" | "icosahedron" | "light" etc.
    let geometryHint: String?
}

/// A 3D position in scene space.
struct Position: Codable, Sendable, Equatable, Hashable {
    let x: Double
    let y: Double
    let z: Double
}

// MARK: - Media

/// A single image for the detail view.
struct SanityMedia: Codable, Sendable, Equatable, Hashable {
    let asset: AssetReference
    let caption: String?
    let alt: String?
}

// MARK: - Video

/// Externally-hosted video (Mux/Cloudflare/Vimeo/etc.). AVPlayer plays HLS
/// natively on iOS.
struct Video: Codable, Sendable, Equatable, Hashable {
    /// HLS or MP4 URL.
    let url: String?
    let posterImage: SanityImage?
    let provider: String?
}

// MARK: - Nonisolated Codable conformance for the top-level decoded type.
//
// Only `Emanation` needs this because it's the type passed to
// `SanityClient.fetch(query:as:)`, whose generic is `T: Decodable & Sendable`.
// The nested types are reached transitively.

nonisolated extension Emanation: Codable {}

// MARK: - Mapping Sanity explorer data → RealityKit visuals

extension ExplorerVisuals {
    /// Bridges the decoded Sanity `Explorer` payload into the scene's
    /// `ExplorerVisuals`. `Double` values are narrowed to `Float` for RealityKit.
    ///
    /// Marked `nonisolated` because the conversion is pure value-type math
    /// (no main-actor state is touched), allowing it to be called from the
    /// nonisolated `ExplorerNode.explorer` computed property.
    nonisolated init(from explorer: Explorer) {
        self.init(
            layerOrder: explorer.layerOrder ?? 0,
            position: explorer.position.map {
                SIMD3<Float>(Float($0.x), Float($0.y), Float($0.z))
            },
            colorHex: explorer.color,
            geometryHint: explorer.geometryHint,
            scale: explorer.scale.map { Float($0) }
        )
    }
}
