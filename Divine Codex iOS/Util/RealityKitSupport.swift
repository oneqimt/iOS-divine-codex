//
//  RealityKitSupport.swift
//  Divine Codex iOS
//
//  Lightweight utility for detecting RealityKit hardware/software support at runtime.
//
//  Created for the Cosmology Explorer.
//
//  Notes:
//  - Even when using RealityKit in a pure 3D (non-AR) context, the underlying
//    hardware requirements are effectively the same as ARKit on iOS.
//  - The most reliable public check is `ARWorldTrackingConfiguration.isSupported`.
//  - This currently maps to A12 Bionic and newer devices (iPhone XS/XR and later).

import Foundation
import ARKit
import RealityKit

enum RealityKitSupport {

    /// Returns `true` if this device can run RealityKit.
    ///
    /// This check is valid whether you plan to use RealityKit in pure 3D mode
    /// or with an AR session.
    static var isSupported: Bool {
        ARWorldTrackingConfiguration.isSupported
    }

    /// A human-readable explanation when RealityKit is not available.
    /// Returns `nil` when support is available.
    static var unsupportedReason: String? {
        guard !isSupported else { return nil }
        return "This device does not support RealityKit. A12 Bionic or newer is required."
    }

    /// Convenience for showing a user-facing message.
    static var unsupportedMessage: String {
        "The Cosmology Explorer requires a device with an A12 Bionic chip or newer (iPhone XS or later)."
    }
}
