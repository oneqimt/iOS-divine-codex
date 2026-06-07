//
//  CosmoExplorerView.swift
//  Divine Codex iOS
//
//  Cosmology Explorer container: spatial Cosmo Stage with full-screen detail push.
//

import SwiftUI

struct CosmoExplorerView: View {

    let explorerViewModel: ExplorerViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()

                CosmoStage(
                    viewModel: explorerViewModel,
                    onSelectNode: { node in
                        explorerViewModel.selectNode(node)
                    }
                )
            }
            .overlay(alignment: .topTrailing) {
                closeButton.padding(16)
            }
            .navigationDestination(item: detailBinding) { node in
                let pair = explorerViewModel.pair(containing: node)
                    ?? CosmoConsortPair(primary: node, consort: nil)
                CosmoDetailView(
                    pair: pair,
                    returnLabel: explorerViewModel.detailBreadcrumb(for: pair)
                ) {
                    explorerViewModel.clearSelection()
                }
            }
        }
        .onAppear { explorerViewModel.didEnterImmersiveScene() }
        .onDisappear { explorerViewModel.didExitImmersiveScene() }
    }

    private var detailBinding: Binding<ExplorerNode?> {
        Binding(
            get: { explorerViewModel.selectedNode },
            set: { newValue in
                if newValue == nil {
                    explorerViewModel.clearSelection()
                } else {
                    explorerViewModel.selectNode(newValue!)
                }
            }
        )
    }

    private var closeButton: some View {
        Button {
            explorerViewModel.didExitImmersiveScene()
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.Colors.primaryText.opacity(0.85))
                .padding(11)
                .background(.ultraThinMaterial, in: Circle())
                .overlay {
                    Circle()
                        .stroke(Theme.Colors.primaryText.opacity(0.12), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Close Cosmology Explorer")
    }
}