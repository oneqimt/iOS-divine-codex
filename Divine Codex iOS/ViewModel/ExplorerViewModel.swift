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

    /// All nodes currently available in the explorer.
    /// For now sourced from local mock data.
    private(set) var nodes: [MockCosmicNode] = []

    /// The node the user has currently selected.
    /// When non-nil, the pointing overlay should be shown.
    var selectedNode: MockCosmicNode?

    /// Whether the immersive RealityKit scene is currently presented.
    /// Useful for coordinating state when entering/leaving the full-screen experience.
    var isImmersiveScenePresented = false

    // MARK: - Init

    init() {
        loadMockData()
    }

    // MARK: - Data Loading (temporary)

    private func loadMockData() {
        nodes = LocalCosmology.nodes
    }

    // MARK: - Selection

    func selectNode(_ node: MockCosmicNode) {
        selectedNode = node
    }

    func clearSelection() {
        selectedNode = nil
    }

    // MARK: - Scene Lifecycle

    func didEnterImmersiveScene() {
        isImmersiveScenePresented = true
        // Future: could trigger prefetching of additional content here
    }

    func didExitImmersiveScene() {
        isImmersiveScenePresented = false
        clearSelection()
        // Future: persist camera position, visited nodes, etc.
    }
}
