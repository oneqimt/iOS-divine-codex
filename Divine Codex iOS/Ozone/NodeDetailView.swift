//
//  NodeDetailView.swift
//  Divine Codex iOS
//
//  The expanded detail state for a node. Used inside ExplorerNodeButton
//  for the tween from compact node representation to full detail card.
//  Black background (no heavy glass for readability in 3D overlay).
//  Title acts as the header (the "original node" has become the detail).
//

import SwiftUI

struct NodeDetailView: View {
    let node: ExplorerNode
    let action: () -> Void  // for close / collapse

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Title as card header (no pill — the node has become the detail)
            Text(node.name)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.Colors.primaryText)

            if let description = node.shortDescription {
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Theme.Colors.primaryText)
                    .lineLimit(6)
            }

            // Close button in the detail
            HStack {
                Spacer()
                Button(action: action) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.Colors.primaryText.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.75))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Theme.Colors.divineGold.opacity(0.3), lineWidth: 1)
                )
        )
        .frame(
            minWidth: Theme.Cards.explorerDetailMinWidth,
            maxWidth: Theme.Cards.explorerDetailMaxWidth,
            alignment: .leading
        )
        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    NodeDetailView(
        node: .emanation(.sample(name: "Monad", type: "Monad")),
        action: {}
    )
    .padding()
    .background(Theme.Colors.background)
}
#endif
