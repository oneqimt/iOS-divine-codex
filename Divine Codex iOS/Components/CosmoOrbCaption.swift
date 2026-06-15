//
//  CosmoOrbCaption.swift
//  Divine Codex iOS
//
//  Unified label stack for cosmology orbs on the spatial stage.
//  Hero (Monad / Pleroma): emanation type + shortDescription.
//  Ring (Aeons): gold title + shortDescription.
//

import SwiftUI

struct CosmoOrbCaption: View {

    private enum Content {
        case hero(ExplorerNode)
        case ring(title: String, shortDescription: String?)
    }

    private let content: Content
    private let heroDiameter: CGFloat?
    private let heroScale: CosmoOrbHeroScale
    private let ringMaxWidth: CGFloat?

    /// Hero orb under Monad or Pleroma.
    init(node: ExplorerNode, diameter: CGFloat, scale: CosmoOrbHeroScale = .standard) {
        content = .hero(node)
        heroDiameter = diameter
        heroScale = scale
        ringMaxWidth = nil
    }

    /// Aeon ring token under one or two small orbs.
    init(title: String, shortDescription: String?, maxWidth: CGFloat) {
        content = .ring(title: title, shortDescription: shortDescription)
        heroDiameter = nil
        heroScale = .standard
        ringMaxWidth = maxWidth
    }

    var body: some View {
        switch content {
        case .hero(let node):
            heroCaption(for: node)
        case .ring(let title, let shortDescription):
            ringCaption(title: title, shortDescription: shortDescription)
        }
    }

    // MARK: - Hero

    @ViewBuilder
    private func heroCaption(for node: ExplorerNode) -> some View {
        let diameter = heroDiameter ?? 120

        VStack(spacing: CosmoOrbTypography.stackSpacingTight) {
            if let type = node.emanationType {
                Text(type.capitalized)
                    .font(.system(size: CosmoOrbTypography.typeSize, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.Colors.divineGold)
                    .textCase(.uppercase)
                    .tracking(0.8)
            }

            if let shortDescription = node.shortDescription {
                Text(shortDescription)
                    .font(.system(
                        size: CosmoOrbTypography.heroBodyFontSize(diameter: diameter, scale: heroScale),
                        weight: .regular,
                        design: .rounded
                    ))
                    .foregroundStyle(Theme.Colors.primaryText.opacity(CosmoOrbTypography.bodyOpacity))
                    .multilineTextAlignment(.center)
                    .lineLimit(CosmoOrbTypography.heroBodyLineLimit(diameter: diameter, scale: heroScale))
                    .frame(maxWidth: CosmoOrbTypography.heroMaxWidth(diameter: diameter))
            }
        }
    }

    // MARK: - Ring

    @ViewBuilder
    private func ringCaption(title: String, shortDescription: String?) -> some View {
        VStack(spacing: CosmoOrbTypography.stackSpacingRing) {
            Text(title)
                .font(.system(size: CosmoOrbTypography.ringTitleSize, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.Colors.divineGold)
                .multilineTextAlignment(.center)
                .lineLimit(CosmoOrbTypography.ringTitleLineLimit)

            if let shortDescription {
                Text(shortDescription)
                    .font(.system(size: CosmoOrbTypography.ringBodySize, weight: .regular, design: .rounded))
                    .foregroundStyle(Theme.Colors.primaryText.opacity(CosmoOrbTypography.ringBodyOpacity))
                    .multilineTextAlignment(.center)
                    .lineLimit(CosmoOrbTypography.ringBodyLineLimit)
            }
        }
        .frame(maxWidth: ringMaxWidth)
    }
}