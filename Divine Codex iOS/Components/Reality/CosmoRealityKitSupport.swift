//
//  CosmoRealityKitSupport.swift
//  Divine Codex iOS
//
//  Runtime check for pure 3D RealityKit (no ARSession).
//

import ARKit
import Foundation
import RealityKit

enum CosmoRealityKitSupport {

    /// Returns `true` if this device can render a basic RealityKit 3D scene.
    static var isSupported: Bool {
        if #available(iOS 18.0, *) {
            return true
        }
        return ARWorldTrackingConfiguration.isSupported
    }

    /// A human-readable explanation when RealityKit is not available.
    static var unsupportedReason: String? {
        guard !isSupported else { return nil }
        return "This device does not support the graphics capabilities required for the Cosmology Explorer."
    }

    static var unsupportedMessage: String {
        "The Cosmology Explorer requires a device capable of running RealityKit (most devices on iOS 18 and later)."
    }
}