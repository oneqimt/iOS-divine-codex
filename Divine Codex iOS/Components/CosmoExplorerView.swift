//
//  CosmoExplorerView.swift
//  Divine Codex iOS
//
//  The new, simplified Cosmology Explorer: a platter carousel of nodes paired
//  with a data-bound detail sidebar. Replaces the free-floating 3D "planets"
//  scene (CosmoScene) with a cleaner, more usable layout.
//
//  Layout adapts to size class:
//   - Regular width (iPad): platter + sidebar side-by-side (split view feel)
//   - Compact width (iPhone): platter full-screen; sidebar as a sheet
//

import SwiftUI

struct CosmoExplorerView: View {

    let explorerViewModel: ExplorerViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dismiss) private var dismiss

    private var nodes: [ExplorerNode] { explorerViewModel.nodes }

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                regularLayout
            } else {
                compactLayout
            }
        }
        .onAppear { explorerViewModel.didEnterImmersiveScene() }
        .onDisappear { explorerViewModel.didExitImmersiveScene() }
    }

    // MARK: - Regular (iPad): side-by-side

    private var regularLayout: some View {
        HStack(spacing: 0) {
            platter
                .frame(maxWidth: .infinity)
                // Cover-dismiss lives over the platter only, so it never
                // collides with the sidebar's own close button.
                .overlay(alignment: .topTrailing) { closeButton.padding(16) }

            if explorerViewModel.selectedNode != nil {
                Divider()
                CosmoSidebar(
                    node: explorerViewModel.selectedNode,
                    onClose: { explorerViewModel.clearSelection() }
                )
                .frame(width: 380)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.85),
                   value: explorerViewModel.selectedNode)
    }

    // MARK: - Compact (iPhone): platter + sheet

    private var compactLayout: some View {
        platter
            .overlay(alignment: .topTrailing) { closeButton.padding(16) }
            .sheet(
                isPresented: Binding(
                    get: { explorerViewModel.selectedNode != nil },
                    set: { if !$0 { explorerViewModel.clearSelection() } }
                )
            ) {
                CosmoSidebar(
                    node: explorerViewModel.selectedNode,
                    onClose: { explorerViewModel.clearSelection() }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
    }

    // MARK: - Shared pieces

    private var platter: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            CosmoPlatter(
                nodes: nodes,
                selection: Binding(
                    get: { explorerViewModel.selectedNode },
                    set: { newValue in
                        if let newValue {
                            explorerViewModel.selectNode(newValue)
                        } else {
                            explorerViewModel.clearSelection()
                        }
                    }
                )
            )
        }
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
