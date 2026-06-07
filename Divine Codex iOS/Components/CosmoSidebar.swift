//
//  CosmoSidebar.swift
//  Divine Codex iOS
//
//  Legacy split-view detail pane — superseded by CosmoDetailView (full-screen push).
//  Kept for reference; not used in the active explorer flow.
//

import SwiftUI

@available(*, deprecated, message: "Use CosmoDetailView with NavigationStack instead.")
struct CosmoSidebar: View {

    let node: ExplorerNode?
    let onClose: () -> Void

    var body: some View {
        Group {
            if let node {
                CosmoDetailView(
                    pair: CosmoConsortPair(primary: node, consort: nil),
                    onBack: onClose
                )
            } else {
                Text("Select a node")
                    .foregroundStyle(Theme.Colors.secondaryText)
            }
        }
    }
}