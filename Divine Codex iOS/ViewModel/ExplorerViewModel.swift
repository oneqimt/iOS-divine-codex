//
//  ExplorerViewModel.swift
//  Divine Codex iOS
//
//  View model that drives the Cosmology Explorer experience.
//
//  Responsibilities (current phase):
//  - Owns the logical graph of cosmic nodes (currently from LocalData mock)
//  - Tracks the currently selected node
//  - Will later coordinate loading from Sanity + the visual scene state
//
//  This is intentionally lightweight to start. We can introduce UseCase/Intent
//  boundaries later if view model synchronization becomes painful.

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
    private func loadLocalHierarchy() {
        nodes = ExplorerNode.localHierarchy()
    }

    /// Merges server data (from Sanity) into the explorer nodes.
    /// Currently appends DivineCodex entries under the Aeon level.
    /// This will evolve as we refine how Barbelo, Sophia, and the Invisibles
    /// should be placed in the tree.
    func updateWithServerData(_ codices: [DivineCodex]) {
        // For now we simply convert incoming DivineCodex entries into .emanation nodes.
        // Later we can be smarter about placement (e.g. only certain slugs go under
        // specific Aeons, filtering, ordering via explorer.layerOrder, etc.).
        let serverNodes = codices.map { ExplorerNode.emanation($0) }

        // Replace any previous server nodes with the fresh ones.
        // Keep the local hierarchy at the top.
        let localNodes = ExplorerNode.localHierarchy()
        nodes = localNodes + serverNodes
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
