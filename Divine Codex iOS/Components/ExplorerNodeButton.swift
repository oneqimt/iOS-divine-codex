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
    var showsDetail: Bool = true   // for 3D scene use vs compact test rows if needed
    var useStrongerBackgroundFor3DCompact: Bool = false  // improves readability when used as floating label in 3D overlay

    var body: some View {
        // For 3D detail cards we skip the GlassEffectContainer to avoid unwanted blur/glass on the solid black card.
        // For compact (especially 2D buttons and 3D compact labels) we use the container for proper Liquid Glass.
        if useStrongerBackgroundFor3DCompact && isSelected && showsDetail {
            Button(action: action) {
                NodeDetailView(node: node, action: action)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
            .buttonStyle(.plain)
            .background(Color.clear)  // detail controls its own solid black bg
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Theme.Colors.divineGold.opacity(0.3), lineWidth: 1)
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: isSelected)
        } else {
            GlassEffectContainer {
                Button(action: action) {
                    if isSelected && showsDetail {
                        NodeDetailView(node: node, action: action)
                            .transition(.scale(scale: 0.8).combined(with: .opacity))
                    } else {
                        NodeLabelView(title: node.name, isEmphasized: isSelected, useStrongerBackgroundFor3D: useStrongerBackgroundFor3DCompact && !isSelected)
                            .transition(.scale(scale: 0.8).combined(with: .opacity))
                    }
                }
                .buttonStyle(.plain)
                .background {
                    if isSelected && showsDetail {
                        Color.clear
                    } else if useStrongerBackgroundFor3DCompact {
                        Capsule()
                            .fill(Color.black.opacity(0.65))
                    } else {
                        Capsule()
                            .fill(Color.black.opacity(0.45))
                            .glassEffect(.clear, in: .capsule)
                    }
                }
                .overlay {
                    if isSelected && showsDetail {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Theme.Colors.divineGold.opacity(0.3), lineWidth: 1)
                    } else {
                        Capsule()
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    }
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.75), value: isSelected)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Unselected") {
    ExplorerNodeButton(
        node: .emanation(.sample(name: "Monad", type: "Monad")),
        isSelected: false,
        action: {}
    )
    .padding()
    .background(Color.black)
}

#Preview("Selected") {
    ExplorerNodeButton(
        node: .emanation(.sample(name: "Pleroma", type: "Pleroma")),
        isSelected: true,
        action: {}
    )
    .padding()
    .background(Color.black)
}
#endif
