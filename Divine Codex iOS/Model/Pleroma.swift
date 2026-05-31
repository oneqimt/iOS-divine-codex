//
//  Pleroma.swift
//  Divine Codex iOS
//
//  The Pleroma (the "Fullness").
//  This represents the divine realm of perfect unity and emanation that exists
//  directly beneath the Monad.
//
//  For now this is treated as local data (like Monad) because the core
//  structure of the upper cosmology is stable and we want to avoid frequent
//  App Store review cycles.
//
//  In the current thinking:
//  - Monad (root, local)
//  - Pleroma (directly beneath Monad, local)
//  - Aeon layer(s) (local for now)
//  - Individual emanations (e.g. Barbelo, Sophia, etc.) pulled from Sanity
//

import Foundation

struct Pleroma: Identifiable, Sendable, Equatable, Hashable {
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

    /// Future: local or remote video / frequency associated with the Pleroma.
    let videoAssetName: String?
}
