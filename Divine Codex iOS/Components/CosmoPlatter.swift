//
//  CosmoPlatter.swift
//  Divine Codex iOS
//
//  A horizontal "platter" carousel of cosmology nodes. Replaces the free-
//  floating 3D "planets" with a clean, snapping carousel of cards. Tapping a
//  card selects it (driving the bound sidebar detail view).
//
//  Pure SwiftUI — no RealityKit. The focused (centered) card scales up to give
//  a spatial, platter-like feel.
//

import SwiftUI

struct CosmoPlatter: View {

    let nodes: [ExplorerNode]

    /// The currently-selected node. Two-way bound so taps update the sidebar
    /// and external selection changes recenter the carousel.
    @Binding var selection: ExplorerNode?

    // Card sizing
    private let cardWidth: CGFloat = 220
    private let cardSpacing: CGFloat = 24

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: cardSpacing) {
                    ForEach(nodes) { node in
                        CosmoPlatterCard(
                            node: node,
                            isSelected: selection?.id == node.id
                        )
                        .frame(width: cardWidth)
                        .id(node.id)
                        .scrollTransition { content, phase in
                            // Focused (centered) card pops forward; neighbors
                            // recede slightly to create the platter feel.
                            content
                                .scaleEffect(phase.isIdentity ? 1.0 : 0.85)
                                .opacity(phase.isIdentity ? 1.0 : 0.6)
                        }
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                selection = node
                                proxy.scrollTo(node.id, anchor: .center)
                            }
                        }
                    }
                }
                .scrollTargetLayout()
                // Generous horizontal padding so the first/last card can
                // settle in the center of the viewport.
                .padding(.horizontal, 60)
                .padding(.vertical, 40)
            }
            .scrollTargetBehavior(.viewAligned)
            .onChange(of: selection?.id) { _, newID in
                guard let newID else { return }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    proxy.scrollTo(newID, anchor: .center)
                }
            }
        }
    }
}

// MARK: - Card

private struct CosmoPlatterCard: View {

    let node: ExplorerNode
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 16) {
            // Visual token for the node (colored orb derived from explorer data).
            Circle()
                .fill(nodeColor.gradient)
                .frame(width: 90, height: 90)
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.25), lineWidth: 1)
                }
                .shadow(color: nodeColor.opacity(0.5), radius: isSelected ? 18 : 8)

            VStack(spacing: 4) {
                if let type = node.emanationType {
                    Text(type.capitalized)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.Colors.divineGold)
                        .textCase(.uppercase)
                        .tracking(1.0)
                }

                Text(node.name)
                    .font(.system(size: 19, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.Colors.primaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.black.opacity(0.4))
                .glassEffect(.clear, in: .rect(cornerRadius: 24))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    isSelected ? Theme.Colors.divineGold.opacity(0.6)
                               : Color.white.opacity(0.12),
                    lineWidth: isSelected ? 2 : 1
                )
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(node.name)
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
    }

    /// Derives a display color from the node's explorer hex, falling back to gold.
    private var nodeColor: Color {
        if let hex = node.explorer?.colorHex, let ui = Self.color(fromHex: hex) {
            return Color(ui)
        }
        return Theme.Colors.divineGold
    }

    private static func color(fromHex hex: String) -> UIColor? {
        let sanitized = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        guard Scanner(string: sanitized).scanHexInt64(&rgb) else { return nil }
        return UIColor(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}

// MARK: - Preview

#if DEBUG
private struct CosmoPlatterPreviewHost: View {
    @State private var selection: ExplorerNode? = .emanation(Emanation.sampleSet[0])

    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            CosmoPlatter(
                nodes: Emanation.sampleSet.map(ExplorerNode.emanation),
                selection: $selection
            )
        }
    }
}

#Preview {
    CosmoPlatterPreviewHost()
}
#endif
