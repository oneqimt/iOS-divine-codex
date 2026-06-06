//
//  ExplorerViewModel.swift
//  Divine Codex iOS
//
//  View model that drives the Cosmology Explorer experience.
//
//  Owned at the application root (created early in Divine_Codex_iOSApp like
//  SanityViewModel, injected via .environment, kept in sync by HomeView's
//  onAppear/onChange of codices). This guarantees zero creation cost on first
//  visit to the Explorer tab and that server data is available no matter which
//  tab is active when the prefetch completes.
//
//  Responsibilities (current phase):
//  - Owns the logical graph of cosmic nodes (local stable + dynamic from Sanity)
//  - Tracks the currently selected node
//  - Coordinates immersive scene entry/exit (for CosmoScene)
//
//  Intentionally lightweight. Local node construction is cached statically
//  (ExplorerNode.localNodes) so updateWithServerData and init do almost no work
//  after the very first access at app launch.

import Foundation
import Observation

@Observable
@MainActor
final class ExplorerViewModel {

    // MARK: - State

    /// The explorer nodes that will be rendered in the Cosmology Explorer.
    /// Every node — the Monad, Pleroma, Aeon, and the Invisibles (Barbelo,
    /// Sophia, etc.) — now comes from Sanity as an `Emanation`. Populated by
    /// `updateWithServerData(_:)`.
    private(set) var nodes: [ExplorerNode] = []

    /// The node the user has currently selected.
    /// When non-nil, the pointing overlay should be shown.
    var selectedNode: ExplorerNode?

    /// Whether the immersive RealityKit scene is currently presented.
    var isImmersiveScenePresented = false

    // MARK: - Init

    init() {
        // The Monad, Pleroma, and Aeon nodes now live in Sanity (as `Emanation`
        // records distinguished by their Emanation Type). We no longer seed the
        // hierarchy from `LocalCosmologySeeds`; `nodes` is populated entirely by
        // `updateWithServerData(_:)` once the server data arrives.
    }

    // MARK: - Data Loading

    /// Replaces the explorer nodes with server data (from Sanity).
    ///
    /// Every node — including the Monad, Pleroma, and Aeon — now comes from
    /// Sanity as an `Emanation`, so there is no longer any local seed data
    /// prepended here. (This is what previously caused the duplicated nodes in
    /// `CosmoScene`: the local seeds and their Sanity equivalents were both
    /// being rendered.)
    ///
    /// Optimized to avoid replacing `nodes` (and thus emitting an @Observable
    /// change notification) if the resulting list would be identical.
    func updateWithServerData(_ emanations: [Emanation]) {
        // Convert incoming Emanation entries into .emanation nodes.
        // Later we can be smarter about placement using `parentId` / `consortId`,
        // filtering, and ordering via explorer.layerOrder.
        let newNodes = emanations.map { ExplorerNode.emanation($0) }

        if newNodes != nodes {
            nodes = newNodes
        }
    }

    // MARK: - Selection

    func selectNode(_ node: ExplorerNode) {
        selectedNode = node
    }

    func clearSelection() {
        selectedNode = nil
    }

    // MARK: - Scene Lifecycle

    func didEnterImmersiveScene() {
        isImmersiveScenePresented = true
    }

    func didExitImmersiveScene() {
        isImmersiveScenePresented = false
        clearSelection()
    }
}
