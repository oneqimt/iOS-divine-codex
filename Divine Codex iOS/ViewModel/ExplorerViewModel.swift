//
//  ExplorerViewModel.swift
//  Divine Codex iOS
//
//  View model that drives the Cosmology Explorer experience.
//
//  Owned at the application root (created early in Divine_Codex_iOSApp like
//  SanityViewModel, injected via .environment, kept in sync by HomeView's
//  onAppear/onChange of emanations). This guarantees zero creation cost on
//  first visit to the Explorer tab and that server data is available no matter
//  which tab is active when the prefetch completes.
//

import Foundation
import Observation

/// Which layer of the cosmology the spatial stage is showing.
enum CosmoStageDepth: Equatable, Sendable {
    case monad
    case pleroma
    case aeons
}

@Observable
@MainActor
final class ExplorerViewModel {

    // MARK: - Flat node list

    /// All emanations as explorer nodes (flat, from Sanity).
    private(set) var nodes: [ExplorerNode] = []

    // MARK: - Hierarchy (derived from parentId / consortId)

    private(set) var monad: ExplorerNode?
    private(set) var pleroma: ExplorerNode?
    private(set) var aeonNodes: [ExplorerNode] = []
    private(set) var consortPairs: [CosmoConsortPair] = []

    /// Current depth on the spatial stage. Always starts at Monad on entry.
    var stageDepth: CosmoStageDepth = .monad

    /// The node driving the full-screen detail push (when non-nil).
    var selectedNode: ExplorerNode?

    /// Whether the immersive explorer is currently presented.
    var isImmersiveScenePresented = false

    // MARK: - Data Loading

    func updateWithServerData(_ emanations: [Emanation]) {
        let newNodes = emanations.map { ExplorerNode.emanation($0) }

        if newNodes != nodes {
            nodes = newNodes
            rebuildHierarchy()
        }
    }

    private func rebuildHierarchy() {
        let byId = Dictionary(uniqueKeysWithValues: nodes.map { ($0.id, $0) })

        monad = nodes.first(where: { $0.emanationType == "monad" })
            ?? nodes.first(where: { $0.parentId == nil })

        if let monadId = monad?.id {
            pleroma = nodes.first(where: {
                $0.parentId == monadId && $0.emanationType == "pleroma"
            })
        } else {
            pleroma = nodes.first(where: { $0.emanationType == "pleroma" })
        }

        if let pleromaId = pleroma?.id {
            aeonNodes = nodes
                .filter { $0.parentId == pleromaId && $0.emanationType == "aeon" }
                .sorted { ($0.emanation.order ?? Int.max) < ($1.emanation.order ?? Int.max) }
        } else {
            aeonNodes = nodes
                .filter { $0.emanationType == "aeon" }
                .sorted { ($0.emanation.order ?? Int.max) < ($1.emanation.order ?? Int.max) }
        }

        consortPairs = Self.buildConsortPairs(from: aeonNodes, lookup: byId)
    }

    /// Groups Aeons into consort pairs when `consortId` is set; otherwise one unit per Aeon.
    private static func buildConsortPairs(
        from aeons: [ExplorerNode],
        lookup: [String: ExplorerNode]
    ) -> [CosmoConsortPair] {
        var consumed = Set<String>()
        var pairs: [CosmoConsortPair] = []

        for node in aeons {
            guard !consumed.contains(node.id) else { continue }

            if let consortId = node.emanation.consortId,
               let partner = lookup[consortId] {
                consumed.insert(node.id)
                consumed.insert(consortId)
                let ordered = [node, partner].sorted {
                    ($0.emanation.order ?? Int.max) < ($1.emanation.order ?? Int.max)
                }
                pairs.append(CosmoConsortPair(primary: ordered[0], consort: ordered[1]))
            } else {
                consumed.insert(node.id)
                pairs.append(CosmoConsortPair(primary: node, consort: nil))
            }
        }

        return pairs
    }

    /// The consort pair containing `node`, if any.
    func pair(containing node: ExplorerNode) -> CosmoConsortPair? {
        consortPairs.first { pair in
            pair.primary.id == node.id || pair.consort?.id == node.id
        }
    }

    // MARK: - Stage navigation

    func resetStage() {
        stageDepth = .monad
        clearSelection()
    }

    func drillToPleroma() {
        guard pleroma != nil else { return }
        withStageAnimation { stageDepth = .pleroma }
    }

    func drillToAeons() {
        guard !displayUnits.isEmpty else { return }
        withStageAnimation { stageDepth = .aeons }
    }

    func drillUp() {
        withStageAnimation {
            switch stageDepth {
            case .monad:
                break
            case .pleroma:
                stageDepth = .monad
            case .aeons:
                stageDepth = .pleroma
            }
            clearSelection()
        }
    }

    /// Ring items — consort pairs when available, otherwise individual Aeons.
    var displayUnits: [CosmoConsortPair] {
        if !consortPairs.isEmpty { return consortPairs }
        return aeonNodes.map { CosmoConsortPair(primary: $0, consort: nil) }
    }

    /// Monad segment in breadcrumbs — type label, not the node's display name ("The One").
    private var monadBreadcrumbLabel: String { monad?.typeLabel ?? "Monad" }
    private var pleromaBreadcrumbLabel: String { pleroma?.name ?? "Pleroma" }

    /// Full hierarchy breadcrumb for the current stage depth.
    var stageBreadcrumb: String {
        switch stageDepth {
        case .monad:
            return monadBreadcrumbLabel
        case .pleroma:
            return "\(monadBreadcrumbLabel) › \(pleromaBreadcrumbLabel)"
        case .aeons:
            return "\(monadBreadcrumbLabel) › \(pleromaBreadcrumbLabel) › Aeons"
        }
    }

    /// Whether the stage breadcrumb can drill up one level (Pleroma / Aeons).
    var canDrillUpFromBreadcrumb: Bool {
        stageDepth != .monad
    }

    /// Breadcrumb shown on detail — extends the stage path with the selection.
    func detailBreadcrumb(for pair: CosmoConsortPair) -> String {
        let selection = pair.displayName
        switch stageDepth {
        case .monad:
            return "\(monadBreadcrumbLabel) › \(selection)"
        case .pleroma:
            return "\(monadBreadcrumbLabel) › \(pleromaBreadcrumbLabel) › \(selection)"
        case .aeons:
            return "\(monadBreadcrumbLabel) › \(pleromaBreadcrumbLabel) › Aeons › \(selection)"
        }
    }

    /// The parent node whose ghost orb drills up one level (nil at Monad).
    var parentGhostNode: ExplorerNode? {
        switch stageDepth {
        case .monad: nil
        case .pleroma: monad
        case .aeons: pleroma
        }
    }

    private func withStageAnimation(_ changes: () -> Void) {
        changes()
    }

    // MARK: - Selection

    func selectNode(_ node: ExplorerNode) {
        selectedNode = node
    }

    func selectPair(_ pair: CosmoConsortPair) {
        selectedNode = pair.primary
    }

    func clearSelection() {
        selectedNode = nil
    }

    // MARK: - Scene lifecycle

    func didEnterImmersiveScene() {
        isImmersiveScenePresented = true
        resetStage()
    }

    func didExitImmersiveScene() {
        isImmersiveScenePresented = false
        resetStage()
    }
}