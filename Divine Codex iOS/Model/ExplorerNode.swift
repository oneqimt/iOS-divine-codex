//
//  ExplorerNode.swift
//  Divine Codex iOS
//
//  A node in the Cosmology Explorer scene. All cosmology content now comes from
//  Sanity as `Emanation` records (Monad, Pleroma, and Aeons are distinguished
//  by their Emanation Type), so this is a thin wrapper around `Emanation` that
//  provides the convenience accessors the scene and detail UI rely on.
//
//  (Previously this enum also wrapped local `Monad` / `Pleroma` / `Aeon` seed
//  types; those have been removed now that the upper hierarchy lives in Sanity.)
//

import Foundation
import simd

/// Represents a single node in the explorer hierarchy that can be rendered in
/// the carousel/scene and displayed in detail overlays. Backed entirely by a
/// Sanity `Emanation`.
enum ExplorerNode: Identifiable, Hashable {
    case emanation(Emanation)

    /// The wrapped emanation.
    var emanation: Emanation {
        switch self {
        case .emanation(let e): return e
        }
    }

    var id: String {
        emanation.id
    }

    /// Display title from Sanity (`coalesce(title, name)` in GROQ).
    var name: String {
        emanation.name ?? "Untitled"
    }

    var title: String { name }

    /// The emanation type as a lowercased string ("monad", "pleroma", "aeon"),
    /// used to drive layout fallbacks in the scene.
    var emanationType: String? {
        emanation.type?.lowercased()
    }

    /// Human-readable type for breadcrumbs and wayfinding ("Monad", "Pleroma", "Aeon").
    var typeLabel: String {
        emanation.type ?? emanationType?.capitalized ?? "Emanation"
    }

    var shortDescription: String? {
        emanation.shortDescription
    }

    /// Visualization data used to position and style the entity in the scene.
    var explorer: ExplorerVisuals? {
        emanation.explorer.map(ExplorerVisuals.init(from:))
    }

    /// Parent relationship for building the tree.
    var parentId: String? {
        emanation.parentId
    }

    /// Optional R2 / HLS hero clip for the spatial orb (Sanity `video.url`).
    var videoURL: URL? {
        guard let raw = emanation.video?.url?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty else { return nil }
        return URL(string: raw)
    }
    
    // MARK - Hash

    // Manual Equatable + Hashable conformance based on stable ID.
    // Swift’s rule: if == is custom, hash(into:) must match — equal values must produce the same hash. Hashing id is the correct partner to id-only equality.
    static func == (lhs: ExplorerNode, rhs: ExplorerNode) -> Bool {
        lhs.id == rhs.id
    }
    // required by Hashable and must stay aligned with ==.
    // Identity is stable Sanity _id only — keeps refetch updates from rebuilding
    // the tree when content changes. hash(into:) must match == (Swift Hashable rule).
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
