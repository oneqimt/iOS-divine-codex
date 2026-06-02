//
//  ExplorerNode.swift
//  Divine Codex iOS
//
//  A unified representation of a node in the Cosmology Explorer scene.
//  This allows us to mix local stable data (Monad, Pleroma, Aeon) with
//  dynamic content coming from Sanity (DivineCodex entries such as Barbelo,
//  Sophia, and the other Invisibles).
//

import Foundation

/// Represents a single node in the explorer hierarchy that can be rendered
/// in the RealityKit scene and displayed in detail overlays.
enum ExplorerNode: Identifiable, Hashable {
    case monad(Monad)
    case pleroma(Pleroma)
    case aeon(Aeon)
    case emanation(DivineCodex)

    var id: String {
        switch self {
        case .monad(let m):     return m.id
        case .pleroma(let p):   return p.id
        case .aeon(let a):      return a.id
        case .emanation(let e): return e.id
        }
    }

    var name: String {
        switch self {
        case .monad(let m):     return m.name
        case .pleroma(let p):   return p.name
        case .aeon(let a):      return a.name
        case .emanation(let e): return e.title ?? "Untitled"
        }
    }

    var shortDescription: String? {
        switch self {
        case .monad(let m):     return m.shortDescription
        case .pleroma(let p):   return p.shortDescription
        case .aeon(let a):      return a.shortDescription
        case .emanation(let e): return e.title   // DivineCodex currently uses title; shortDescription can be added later
        }
    }

    /// Visualization data used to position and style the entity in RealityKit.
    var explorer: ExplorerVisuals? {
        switch self {
        case .monad(let m):     return m.explorer
        case .pleroma(let p):   return p.explorer
        case .aeon(let a):      return a.explorer
        case .emanation(_):
            // DivineCodex can carry explorer overrides in its explorer field
            // For now we return nil — we'll map this properly once we have
            // the actual explorer data coming from Sanity for Barbelo/Sophia.
            return nil
        }
    }

    /// Parent relationship for building the tree.
    /// Only Aeon currently carries a parentId in our local model.
    var parentId: String? {
        switch self {
        case .aeon(let a): return a.parentId
        default:           return nil
        }
    }

    // Manual Equatable + Hashable conformance based on stable ID.
    // This avoids requiring all wrapped types (Monad, Pleroma, Aeon, DivineCodex)
    // to conform to Equatable right now.
    static func == (lhs: ExplorerNode, rhs: ExplorerNode) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Convenience builders

extension ExplorerNode {
    /// Cached local hierarchy (Monad + Pleroma + Aeons).
    /// Computed once (static) to avoid repeated construction/allocation on every
    /// updateWithServerData or VM init. The seed data is stable.
    static let localNodes: [ExplorerNode] = {
        var nodes: [ExplorerNode] = []
        nodes.append(.monad(LocalCosmologySeeds.monad))
        nodes.append(.pleroma(LocalCosmologySeeds.pleroma))
        for aeon in LocalCosmologySeeds.aeons {
            nodes.append(.aeon(aeon))
        }
        return nodes
    }()

    /// Returns the cached local top-level nodes.
    /// Kept for API compatibility with existing call sites.
    static func localHierarchy() -> [ExplorerNode] {
        localNodes
    }
}
