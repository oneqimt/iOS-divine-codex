//
//  RealityKitSupport.swift
//  Divine Codex iOS
//
//  Lightweight utility for detecting RealityKit hardware/software support at runtime.
//
//  Created for the Cosmology Explorer.
//
//  Important:
//  - The Cosmology Explorer currently uses RealityKit in **pure 3D mode** (no ARSession).
//  - `ARWorldTrackingConfiguration.isSupported` is overly strict for non-AR use cases.
//  - We therefore use a more permissive check for modern iOS devices while still
//    falling back to the ARKit check on older OS versions.

import Foundation
import ARKit
import RealityKit

enum RealityKitSupport {

    /// Returns `true` if this device can render a RealityKit 3D scene.
    ///
    /// This is intentionally more permissive than `ARWorldTrackingConfiguration.isSupported`
    /// because the current implementation uses pure RealityKit (PerspectiveCamera + RealityView)
    /// with no AR world tracking or ARSession.
    static var isSupported: Bool {
        // On iOS 18 and later, the vast majority of devices can render basic
        // RealityKit scenes. This is the primary path for our pure-3D Cosmology Explorer.
        if #available(iOS 18.0, *) {
            return true
        }

        // Fallback for older OS versions: use the stricter ARKit world tracking check.
        return ARWorldTrackingConfiguration.isSupported
    }

    /// A human-readable explanation when RealityKit is not available.
    /// Returns `nil` when support is available.
    static var unsupportedReason: String? {
        guard !isSupported else { return nil }
        return "This device does not support the graphics capabilities required for the Cosmology Explorer."
    }

    /// Convenience for showing a user-facing message.
    static var unsupportedMessage: String {
        "The Cosmology Explorer requires a device capable of running RealityKit (most devices on iOS 18 and later)."
    }
}
