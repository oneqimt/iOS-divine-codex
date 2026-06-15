//
//  CosmoOrbTypography.swift
//  Divine Codex iOS
//
//  Shared type sizes, colors, and diameter-based scaling for cosmology orb captions.
//

import SwiftUI

/// Hero caption scale — Monad (emphasis) vs Pleroma / standard colored orbs.
enum CosmoOrbHeroScale {
    case standard
    case emphasis
}

enum CosmoOrbTypography {

    // MARK: - Fixed sizes

    static let typeSize: CGFloat = 10
    static let ringTitleSize: CGFloat = 11
    static let ringBodySize: CGFloat = 10

    static let stackSpacingTight: CGFloat = 3
    static let stackSpacingRing: CGFloat = 3

    // MARK: - Colors

    static let bodyOpacity: CGFloat = 0.9
    static let ringBodyOpacity: CGFloat = 0.85

    // MARK: - Hero (diameter-driven)

    static func heroBodyFontSize(diameter: CGFloat, scale: CosmoOrbHeroScale) -> CGFloat {
        switch scale {
        case .standard:
            diameter > 100 ? 14 : (diameter > 60 ? 12 : 10)
        case .emphasis:
            diameter > 100 ? 18 : (diameter > 60 ? 14 : 11)
        }
    }

    static func heroBodyLineLimit(diameter: CGFloat, scale: CosmoOrbHeroScale) -> Int {
        switch scale {
        case .standard:
            diameter > 100 ? 4 : 3
        case .emphasis:
            4
        }
    }

    static func heroMaxWidth(diameter: CGFloat) -> CGFloat {
        diameter + 40
    }

    // MARK: - Ring (Aeons)

    static let ringTitleLineLimit = 2
    static let ringBodyLineLimit = 3
}