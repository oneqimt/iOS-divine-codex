//
//  ExplorerNodeButton.swift
//  Divine Codex iOS
//
//  A beautiful, tappable Liquid Glass "node" button used in the Cosmology Explorer.
//
//  These represent the different points in the hierarchy:
//  - Monad, Pleroma, Aeons (local)
//  - Barbelo, Sophia, and the other Invisibles (from Sanity)
//
//  This is intentionally designed as an interactive button (similar to
//  CompactOptionButton patterns) rather than a passive card. It supports
//  selection state and will be used both in 2D overlays and potentially
//  as 2D representations floating in/near the 3D scene.
//

import SwiftUI

struct ExplorerNodeButton: View {
    let node: ExplorerNode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(node.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(isSelected ? Theme.Colors.background : Theme.Colors.primaryText)

                if let shortDesc = node.shortDescription, !shortDesc.isEmpty {
                    Text(shortDesc)
                        .font(.system(size: 11))
                        .foregroundStyle(isSelected ? Theme.Colors.background.opacity(0.7) : Theme.Colors.secondaryText)
                        .lineLimit(2)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Theme.Colors.divineGold : Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected ? Theme.Colors.divineGold.opacity(0.6) : Color.white.opacity(0.15),
                        lineWidth: 1
                    )
            )
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.18), value: isSelected)
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
    .sacredBackground()
}

#Preview("Selected") {
    ExplorerNodeButton(
        node: .pleroma(LocalCosmologySeeds.pleroma),
        isSelected: true,
        action: {}
    )
    .padding()
    .sacredBackground()
}
