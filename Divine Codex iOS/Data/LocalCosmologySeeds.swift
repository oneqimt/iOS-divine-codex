//
//  LocalCosmologySeeds.swift
//  Divine Codex iOS
//
//  Stable, local-first seed data for the top of the cosmology hierarchy.
//
//  Current intended structure (subject to refinement):
//  - Monad (root, local)
//  - Pleroma (directly beneath the Monad, local)
//  - Aeon layer(s) (local for now) — e.g. the 13th Aeon containing the 24 Invisibles
//  - Individual high emanations (Barbelo, Sophia, etc.) pulled dynamically from Sanity
//
//  The 24 Invisibles are the twelve syzygies (divine pairs) that reside in the 13th Aeon.
//
//  Keeping the upper levels local avoids frequent App Store review cycles.
//

import Foundation
import simd

enum LocalCosmologySeeds {

    // MARK: - The Monad (Root)

    static let monad = Monad(
        id: "monad",
        name: "Monad",
        shortDescription: "The Ineffable Source. The One beyond all names and forms. The Divine Spark within each soul is a living fractal of this primordial unity.",
        body: nil,
        imageAssetName: nil,
        explorer: ExplorerVisuals(
            layerOrder: 0,
            position: SIMD3<Float>(0, 14, 0),
            colorHex: "#F5E8C7",
            geometryHint: "light",
            scale: 2.0
        ),
        videoAssetName: nil
    )

    // MARK: - The Pleroma (directly beneath the Monad)

    static let pleroma = Pleroma(
        id: "pleroma",
        name: "Pleroma",
        shortDescription: "The Fullness. The divine realm of perfect unity and emanation that exists directly beneath the Monad.",
        body: nil,
        imageAssetName: nil,
        explorer: ExplorerVisuals(
            layerOrder: 10,
            position: SIMD3<Float>(0, 9, 0),
            colorHex: "#C9A227",
            geometryHint: "sphere",
            scale: 2.2
        ),
        videoAssetName: nil
    )

    // MARK: - Aeon Layer(s)

    static let aeons: [Aeon] = [
        Aeon(
            id: "thirteenth-aeon",
            name: "Aeon",
            shortDescription: "The Region of Righteousness. Home of the 24 Invisibles and the place from which Sophia gazed upward and began her sacred descent.",
            body: nil,
            imageAssetName: nil,
            explorer: ExplorerVisuals(
                layerOrder: 20,
                position: SIMD3<Float>(0, 4, 0),
                colorHex: "#A78BFA",
                geometryHint: "sphere",
                scale: 1.5
            ),
            parentId: "pleroma",
            videoAssetName: nil
        )
    ]
}
