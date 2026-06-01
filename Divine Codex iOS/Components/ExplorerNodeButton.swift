//
//  ExplorerNodeButton.swift
//  Divine Codex iOS
//
//  A beautiful, tappable Liquid Glass button representing a node in the
//  Cosmology Explorer (Monad, Pleroma, Aeons, Barbelo, Sophia, Invisibles, etc.).
//
//  Uses NodeLabelView for consistent title rendering across 2D buttons and
//  3D scene attachments. Applies Liquid Glass treatment matching the TabBarView.
//

import SwiftUI

struct ExplorerNodeButton: View {
    let node: ExplorerNode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        GlassEffectContainer {
            Button(action: action) {
                NodeLabelView(title: node.name, isEmphasized: isSelected)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
            }
            .buttonStyle(.plain)
            .background {
                Capsule()
                    .fill(Color.black.opacity(0.45))
                    .glassEffect(.clear, in: .capsule)
            }
            .overlay {
                if isSelected {
                    Capsule()
                        .fill(.clear)
                        .glassEffect(
                            .regular.tint(Theme.Colors.divineGold.opacity(0.35)).interactive(),
                            in: .capsule
                        )
                }
            }
            .overlay {
                Capsule()
                    .stroke(
                        isSelected
                            ? Theme.Colors.divineGold.opacity(0.55)
                            : Color.white.opacity(0.12),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            }
            .scaleEffect(isSelected ? 1.04 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
}

// MARK: - Preview

#Preview("Unselected") {
    ExplorerNodeButton(
        node: .monad(LocalCosmologySeeds.monad),
        isSelected: false,
        action: {}
    )
    .padding()
    .background(Color.black)
}

#Preview("Selected") {
    ExplorerNodeButton(
        node: .pleroma(LocalCosmologySeeds.pleroma),
        isSelected: true,
        action: {}
    )
    .padding()
    .background(Color.black)
}
