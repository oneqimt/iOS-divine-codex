//
//  CosmoNodeOrb.swift
//  Divine Codex iOS
//
//  Reusable colored orb token for a cosmology node on the spatial stage.
//

import SwiftUI

struct CosmoNodeOrb: View {

    let node: ExplorerNode
    var diameter: CGFloat = 120
    var isEmphasized: Bool = false
    var showsLabel: Bool = true

    var body: some View {
        VStack(spacing: 10) {
            Circle()
                .fill(nodeColor.gradient)
                .frame(width: diameter, height: diameter)
                .overlay {
                    Circle()
                        .stroke(.white.opacity(isEmphasized ? 0.45 : 0.22), lineWidth: isEmphasized ? 2 : 1)
                }
                .shadow(color: nodeColor.opacity(isEmphasized ? 0.65 : 0.35), radius: isEmphasized ? 22 : 10)

            if showsLabel {
                CosmoOrbCaption(node: node, diameter: diameter)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(node.title)
        .accessibilityValue(node.shortDescription ?? "")
    }

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