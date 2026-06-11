//
//  CosmoOrbEntityBuilder.swift
//  Divine Codex iOS
//
//  Builds a spinnable cosmology orb: outer shell + center pulse dot.
//

import RealityKit
import UIKit
import simd

enum CosmoOrbEntityBuilder {

    /// Violet ↔ green palette for the Monad center pulse.
    static let pulseViolet = UIColor(red: 0.48, green: 0.32, blue: 0.95, alpha: 1.0)
    static let pulseGreen = UIColor(red: 0.22, green: 0.82, blue: 0.52, alpha: 1.0)

    static func pulseColor(blend greenAmount: Float) -> UIColor {
        let t = CGFloat(min(max(greenAmount, 0), 1))
        let inverse = 1 - t
        let red = 0.48 * inverse + 0.22 * t
        let green = 0.32 * inverse + 0.82 * t
        let blue = 0.95 * inverse + 0.52 * t
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }

    static func pulseScale(phase: Float) -> Float {
        1.0 + 0.08 * sin(phase * 2.2)
    }

    static func pulseBlend(phase: Float) -> Float {
        0.5 + 0.9 * sin(phase * 2.2)
    }

    /// `spinGroup` holds the shell and is what we rotate. The center dot is a
    /// sibling pinned at the origin so it stays at the geometric center.
    static func makeOrbRoot(for node: ExplorerNode, radius: Float) -> Entity {
        let root = Entity()
        root.name = "CosmoOrbRoot"

        let spinGroup = Entity()
        spinGroup.name = "spinGroup"

        let shellColor = (colorFromHex(node.explorer?.colorHex) ?? .white).withAlphaComponent(0.42)
        let shellMesh = MeshResource.generateSphere(radius: radius)
        let shellMaterial = SimpleMaterial(color: shellColor, isMetallic: false)
        let shell = ModelEntity(mesh: shellMesh, materials: [shellMaterial])
        shell.name = "shell"
        spinGroup.addChild(shell)
        root.addChild(spinGroup)

        let dotRadius = radius * 0.1
        let dotMesh = MeshResource.generateSphere(radius: dotRadius)
        let dotMaterial = SimpleMaterial(color: pulseViolet, isMetallic: false)
        let dot = ModelEntity(mesh: dotMesh, materials: [dotMaterial])
        dot.name = "centerPulse"
        dot.position = .zero
        root.addChild(dot)

        return root
    }

    private static func colorFromHex(_ hex: String?) -> UIColor? {
        guard let hex else { return nil }
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
