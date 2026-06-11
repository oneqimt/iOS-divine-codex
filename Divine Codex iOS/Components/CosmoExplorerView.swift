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

    @State private var isStageReady = false
    @State private var loadProgress = 0.0

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()

                CosmoStage(
                    viewModel: explorerViewModel,
                    onSelectNode: { node in
                        explorerViewModel.selectNode(node)
                    },
                    onMonadReady: {
                        withAnimation(.easeOut(duration: 0.35)) {
                            isStageReady = true
                            loadProgress = 1.0
                        }
                    }
                )
                .opacity(isStageReady ? 1 : 0)

                if !isStageReady {
                    enteringOverlay
                }
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
        .onAppear {
            explorerViewModel.didEnterImmersiveScene()
            isStageReady = false
            loadProgress = 0.08
            startProgressAnimation()
        }
        .task {
            try? await Task.sleep(for: .seconds(5))
            guard !isStageReady else { return }
            withAnimation(.easeOut(duration: 0.35)) {
                isStageReady = true
                loadProgress = 1.0
            }
        }
        .onDisappear {
            explorerViewModel.didExitImmersiveScene()
            isStageReady = false
            loadProgress = 0
        }
    }

    private var enteringOverlay: some View {
        VStack(spacing: 20) {
            ProgressView(value: loadProgress, total: 1.0)
                .tint(Theme.Colors.divineGold)
                .frame(maxWidth: 220)

            Text("Preparing the Monad…")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background.opacity(0.96))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Preparing the cosmology explorer")
    }

    private func startProgressAnimation() {
        Task { @MainActor in
            while !isStageReady && loadProgress < 0.9 {
                try? await Task.sleep(for: .milliseconds(140))
                guard !isStageReady else { break }
                loadProgress = min(loadProgress + 0.06, 0.9)
            }
        }
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