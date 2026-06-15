//
//  CosmoConsortPair.swift
//  Divine Codex iOS
//
//  A consort pair (or singleton Aeon) shown as one unit on the Cosmo Stage.
//  Built from `consortId` when populated in Sanity; until then each Aeon
//  appears as its own unit with `consort == nil`.
//

import Foundation

/// One visual unit on the Aeon ring — either a linked pair or a lone Aeon.
struct CosmoConsortPair: Identifiable, Hashable, Sendable {
    let primary: ExplorerNode
    let consort: ExplorerNode?

    var id: String { primary.id }

    /// Title line for breadcrumbs and detail (one or both names).
    var displayName: String {
        if let consort {
            return "\(primary.name) · \(consort.name)"
        }
        return primary.name
    }

    /// Bare name(s) under the ring orb(s).
    var ringTitle: String {
        if let consort {
            return "\(primary.title) · \(consort.title)"
        }
        return primary.title
    }

    /// Subtitle under the ring title.
    var ringShortDescription: String? {
        primary.shortDescription
    }

    /// Nodes to surface in detail (one or two).
    var members: [ExplorerNode] {
        if let consort { return [primary, consort] }
        return [primary]
    }
}