//
//  Monad.swift
//  Divine Codex iOS
//
//  The absolute root of the cosmology — the Ineffable One, the Source.
//  This is always local data because it changes extremely rarely.
//
//  In the CosmoScene this sits at the very top of the visual hierarchy.
//

import Foundation
import simd

struct Monad: Identifiable, Sendable, Equatable, Hashable {
    let id: String
    let name: String

    /// Short contemplative description (used in overlays, tooltips, etc.).
    let shortDescription: String?

    /// Rich content for the detail overlay when this node is selected.
    /// Reuses the same PortableTextBlock structure as Sanity content for consistency.
    let body: [PortableTextBlock]?

    /// Optional reference to a local image asset name.
    let imageAssetName: String?

    /// Scene visualization configuration (position, color, scale, geometry hint).
    let explorer: ExplorerVisuals?

    /// Future: local or remote video / frequency associated with the Monad.
    let videoAssetName: String?
}
