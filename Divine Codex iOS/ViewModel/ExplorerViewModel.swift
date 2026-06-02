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
    /// This combines local stable data (Monad, Pleroma, Aeons) with dynamic
    /// content coming from Sanity (Barbelo, Sophia, and other Invisibles).
    private(set) var nodes: [ExplorerNode] = []

    /// The node the user has currently selected.
    /// When non-nil, the pointing overlay should be shown.
    var selectedNode: ExplorerNode?

    /// Whether the immersive RealityKit scene is currently presented.
    var isImmersiveScenePresented = false

    // MARK: - Init

    init() {
        loadLocalHierarchy()
    }

    // MARK: - Data Loading

    /// Loads the local top of the hierarchy (Monad → Pleroma → Aeons).
    /// Uses the cached static from ExplorerNode so the (tiny) construction of
    /// the three seed nodes only happens once in the lifetime of the app.
    private func loadLocalHierarchy() {
        nodes = ExplorerNode.localNodes
    }

    /// Merges server data (from Sanity) into the explorer nodes.
    /// Currently appends DivineCodex entries under the Aeon level.
    /// This will evolve as we refine how Barbelo, Sophia, and the Invisibles
    /// should be placed in the tree.
    ///
    /// Optimized to avoid replacing `nodes` (and thus emitting an @Observable
    /// change notification) if the resulting list would be identical.
    func updateWithServerData(_ codices: [DivineCodex]) {
        // For now we simply convert incoming DivineCodex entries into .emanation nodes.
        // Later we can be smarter about placement (e.g. only certain slugs go under
        // specific Aeons, filtering, ordering via explorer.layerOrder, etc.).
        let serverNodes = codices.map { ExplorerNode.emanation($0) }

        // Replace any previous server nodes with the fresh ones.
        // Keep the local hierarchy at the top.
        let newNodes = ExplorerNode.localNodes + serverNodes

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
