//
//  Aeon.swift
//  Divine Codex iOS
//
//  Represents an Aeon or a grouping/layer within the Pleroma.
//  For now these are local because they are relatively stable.
//
//  In the current model, Aeons sit directly under the Monad and above
//  individual emanations such as Barbelo and Sophia.
//

import Foundation

struct Aeon: Identifiable, Sendable, Equatable, Hashable {
    let id: String
    let name: String

    /// Short contemplative description.
    let shortDescription: String?

    /// Rich content for the detail overlay.
    let body: [PortableTextBlock]?

    /// Optional local image asset.
    let imageAssetName: String?

    /// Scene visualization configuration.
    let explorer: ExplorerVisuals?

    /// Reference to parent (usually the Monad, or another Aeon in deeper hierarchies).
    let parentId: String?

    /// Future support for associated frequencies / utterances.
    let videoAssetName: String?
}
