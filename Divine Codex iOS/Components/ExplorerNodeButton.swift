//
//  ExplorerNodeButton.swift
//  Divine Codex iOS
//
//  A beautiful, tappable Liquid Glass button representing a node in the
//  Cosmology Explorer (Monad, Pleroma, Aeons, Barbelo, Sophia, Invisibles, etc.).
//
//  Currently shows only the title. The short description will be used in
//  the detail overlay/popup when a node is selected.
//

import SwiftUI

struct ExplorerNodeButton: View {
    let node: ExplorerNode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(node.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isSelected ? Theme.Colors.background : Theme.Colors.primaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
        }
        .background(
            Capsule()
                .fill(isSelected ? Theme.Colors.divineGold : Color.black.opacity(0.10))
        )
        .glassEffect(.clear, in: .capsule)
        .overlay(
            Capsule()
                .stroke(
                    isSelected ? Theme.Colors.divineGold.opacity(0.5) : Color.white.opacity(0.12),
                    lineWidth: 1
                )
        )
        .scaleEffect(isSelected ? 1.03 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
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
