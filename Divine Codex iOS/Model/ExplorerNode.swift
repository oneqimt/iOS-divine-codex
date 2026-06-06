//
//  ExplorerNode.swift
//  Divine Codex iOS
//
//  A unified representation of a node in the Cosmology Explorer scene.
//  This allows us to mix local stable data (Monad, Pleroma, Aeon) with
//  dynamic content coming from Sanity (`Emanation` entries such as Barbelo,
//  Sophia, and the other Invisibles).
//

import Foundation
import simd

/// Represents a single node in the explorer hierarchy that can be rendered
/// in the RealityKit scene and displayed in detail overlays.
enum ExplorerNode: Identifiable, Hashable {
    case monad(Monad)
    case pleroma(Pleroma)
    case aeon(Aeon)
    case emanation(Emanation)

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
        case .emanation(let e): return e.name ?? "Untitled"
        }
    }

    /// The emanation type as a lowercased string ("monad", "pleroma", "aeon").
    /// Drives layout fallbacks in the scene when Sanity `explorer.position`
    /// data is missing. Local nodes report their type directly; server
    /// emanations use their `type` field.
    var emanationType: String? {
        switch self {
        case .monad:            return "monad"
        case .pleroma:          return "pleroma"
        case .aeon:             return "aeon"
        case .emanation(let e): return e.type?.lowercased()
        }
    }

    var shortDescription: String? {
        switch self {
        case .monad(let m):     return m.shortDescription
        case .pleroma(let p):   return p.shortDescription
        case .aeon(let a):      return a.shortDescription
        case .emanation(let e): return e.shortDescription
        }
    }

    /// Visualization data used to position and style the entity in RealityKit.
    var explorer: ExplorerVisuals? {
        switch self {
        case .monad(let m):     return m.explorer
        case .pleroma(let p):   return p.explorer
        case .aeon(let a):      return a.explorer
        case .emanation(let e): return e.explorer.map(ExplorerVisuals.init(from:))
        }
    }

    /// Parent relationship for building the tree.
    /// Local Aeons carry a parentId; server emanations carry `parentId` directly.
    var parentId: String? {
        switch self {
        case .aeon(let a):      return a.parentId
        case .emanation(let e): return e.parentId
        default:                return nil
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

