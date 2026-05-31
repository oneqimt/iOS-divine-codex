//
//  Node.swift
//  Divine Codex iOS
//
//  A reusable Liquid Glass styled component for displaying an ExplorerNode
//  in the Cosmology Explorer.
//
//  This component will be used in two contexts:
//  1. As the 2D "pointing overlay" / detail card when a node is selected.
//  2. Potentially as visual labels or cards in the 3D scene (via billboards or 2D overlays).
//
//  Design goals:
//  - Beautiful, contemplative, mystical aesthetic using the app's Liquid Glass language.
//  - Clear visual hierarchy (title, short description, optional rich content).
//  - Easy to compose with the existing Theme system.
//

import SwiftUI

struct Node: View {
    let node: ExplorerNode

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Title
            Text(node.name)
                .font(Theme.Fonts.heroTitle)
                .foregroundStyle(Theme.Colors.primaryText)
                .multilineTextAlignment(.leading)

            // Short description
            if let shortDesc = node.shortDescription, !shortDesc.isEmpty {
                Text(shortDesc)
                    .font(Theme.Fonts.body)
                    .foregroundStyle(Theme.Colors.secondaryText)
                    .multilineTextAlignment(.leading)
            }

            // TODO: Rich body content (PortableText renderer)
            // if let body = node.body, !body.isEmpty {
            //     PortableTextView(blocks: body)
            // }

            // TODO: Image / media support
            // TODO: Action buttons (e.g. "Begin Journey", frequencies, etc.)
        }
        .padding(Theme.Spacing.lg)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                .stroke(Theme.Colors.primaryText.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Preview

#Preview {
    // Temporary preview using a local seed
    Node(node: .monad(LocalCosmologySeeds.monad))
        .padding()
        .sacredBackground()
}
