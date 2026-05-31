//
//  CosmoScene.swift
//  Divine Codex iOS
//
//  The full-screen immersive RealityKit Cosmology Explorer.
//
//  Currently uses local mock data. This will later be driven by the
//  ExplorerViewModel + content loaded from Sanity.
//
//  Design notes:
//  - Pure 3D for now (no AR session).
//  - Free camera movement (pan/orbit/zoom) is the goal.
//  - Node selection will eventually drive a 2D SwiftUI pointing overlay.
//
//  ⚠️ See the RealityViewContent visibility warning inside the body below.

// MARK: - The 24 Invisibles (Definition)
//
// The 24 Invisibles are twelve sacred syzygies (divine masculine + feminine pairs)
// that dwell in the 13th Aeon, also called the Region of Righteousness.
// They represent perfect divine balance and are a core part of the Gnostic
// cosmology we are visualizing in this scene.
//
// In our current model they will eventually live under the "Aeon" layer
// (specifically the 13th Aeon), with Barbelo and Sophia being two of the
// most important individual emanations we surface from Sanity data.

import SwiftUI
import RealityKit
import simd

struct CosmoScene: View {

    /// The explorer view model containing the combined local + server nodes.
    /// Passed in from ExplorerView so we have access to the built node list.
    let explorerViewModel: ExplorerViewModel

    /// Access to server data (DivineCodex entries for Barbelo, Sophia, etc.)
    @Environment(SanityViewModel.self) private var sanity

    // References to key entities so we can perform hit testing from gestures.
    @State private var rootEntity: Entity?
    @State private var cameraEntity: Entity?

    // Simple visual feedback for selection during early development.
    @State private var highlightedEntity: Entity?

    /// Used to dismiss the fullScreenCover from inside the immersive experience.
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Main immersive content (full bleed)
            Group {
                if RealityKitSupport.isSupported {
                    // IMPORTANT: RealityViewContent Visibility Gotcha
                    //
                    // Do NOT reference RealityViewContent (or similar RealityView* types)
                    // outside of the RealityView closure at the top level of this file.
                    //
                    // In some Xcode / SDK combinations the symbol is not visible until
                    // you are inside the closure after importing RealityKit. Explicitly
                    // typing the parameter or using it in a helper function signature
                    // can produce "Cannot find RealityViewContent" errors.
                    //
                    // This is why all scene construction currently lives directly
                    // inside `RealityView { content in ... }` instead of being extracted
                    // into a separate setup function.
                    GeometryReader { geometry in
                        RealityView { content in
                            // Root entity
                            let root = Entity()
                            root.name = "CosmologyRoot"

                            // Basic lighting
                            let light = DirectionalLight()
                            light.light.intensity = 1200
                            light.position = [0, 10, 0]
                            root.addChild(light)

                            // TEMP: Still rendering with old mock data while we migrate
                            // to the new ExplorerNode system. We will bind real data next.
                            for node in LocalCosmology.nodes {
                                let entity = makeEntity(for: node)
                                root.addChild(entity)
                            }

                            content.add(root)

                            // Custom camera entity (gives us control later for map-style navigation)
                            let camera = PerspectiveCamera()
                            camera.position = SIMD3<Float>(0, 8, 18)
                            camera.look(at: SIMD3<Float>(0, 4, 0),
                                        from: camera.position,
                                        relativeTo: nil)
                            content.add(camera)

                            // Store references for hit testing from gestures.
                            // We dispatch to main to avoid modifying state during the make closure.
                            DispatchQueue.main.async {
                                rootEntity = root
                                cameraEntity = camera
                            }
                        }
                        .gesture(
                            SpatialTapGesture()
                                .onEnded { value in
                                    let tapLocation = value.location
                                    handleTap(at: tapLocation, in: geometry.size)
                                }
                        )
                    }
                } else {
                    UnsupportedRealityKitView()
                }
            }
            .ignoresSafeArea()

            // Dismiss button (always available, respects safe area)
            closeButton
                .padding(.top, 8)
                .padding(.trailing, 20)
                .safeAreaPadding(.top)
        }
        .onAppear {
            explorerViewModel.didEnterImmersiveScene()

            // TEMP: Log what we received from Sanity so we can see the data flowing.
            // Later we will map these DivineCodex entries (especially Barbelo & Sophia)
            // into the 3D scene alongside our local Monad / Pleroma / Aeon objects.
            print("=== CosmoScene received \(sanity.codices.count) DivineCodex entries from Sanity ===")
            for codex in sanity.codices {
                print("  - \(codex.title ?? "Untitled")")
            }

            print("=== Explorer nodes in view model: \(explorerViewModel.nodes.count) ===")
            for node in explorerViewModel.nodes {
                print("  - \(node.name)")
            }
        }
        .onDisappear {
            explorerViewModel.didExitImmersiveScene()
        }
    }

    // MARK: - Close Button

    private var closeButton: some View {
        Button {
            explorerViewModel.didExitImmersiveScene()
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.Colors.primaryText.opacity(0.85))
                .padding(11)
                .background(.ultraThinMaterial, in: Circle())
                .overlay {
                    Circle()
                        .stroke(Theme.Colors.primaryText.opacity(0.12), lineWidth: 1)
                }
        }
        .accessibilityLabel("Close Cosmology Explorer")
    }

    // MARK: - Helpers

    private func makeEntity(for node: MockCosmicNode) -> Entity {
        let visuals = node.explorer

        let radius: Float = (visuals?.scale ?? 0.8) * 0.5

        let mesh: MeshResource = switch visuals?.geometryHint {
        case "sphere", "light":   .generateSphere(radius: radius)
        case "octahedron":        .generateBox(size: radius * 1.4)
        case "icosahedron":       .generateSphere(radius: radius)
        case "torus":             .generateSphere(radius: radius) // placeholder
        default:                  .generateSphere(radius: radius)
        }

        let material = SimpleMaterial(
            color: colorFromHex(visuals?.colorHex) ?? .white,
            isMetallic: false
        )

        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.name = node.id
        entity.position = visuals?.worldPosition ?? .zero

        // Attach lightweight component so we can map back to logical node on tap
        entity.components.set(MockNodeComponent(nodeId: node.id))

        // Add collision so we can perform proper 3D hit testing / ray casts.
        entity.components.set(CollisionComponent(shapes: [.generateSphere(radius: radius * 1.2)]))

        return entity
    }

    private func colorFromHex(_ hex: String?) -> UIColor? {
        guard let hex = hex else { return nil }
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }

    // MARK: - Hit Testing

    private func handleTap(at location: CGPoint, in viewSize: CGSize) {
        guard let root = rootEntity,
              let camera = cameraEntity else {
            return
        }

        // Generate a world-space ray from the tap location through the camera.
        let (origin, direction) = makeRayVectors(from: location, viewSize: viewSize, camera: camera)

        guard let scene = root.scene else {
            print("Scene not yet available for hit testing")
            return
        }

        // Perform raycast against collision shapes in the scene.
        let hits = scene.raycast(
            origin: origin,
            direction: direction,
            length: 1000,
            query: .nearest
        )

        // Find the first hit that corresponds to one of our cosmic nodes.
        for hit in hits {
            if let component = hit.entity.components[MockNodeComponent.self],
               let node = explorerViewModel.nodes.first(where: { $0.id == component.nodeId }) {

                // Clear previous highlight
                highlightedEntity?.scale = [1, 1, 1]
                highlightedEntity = hit.entity
                hit.entity.scale = [1.4, 1.4, 1.4]   // Simple "selected" pulse

                explorerViewModel.selectNode(node)
                print("✓ Selected node: \(node.name) (id: \(node.id))")
                return
            }
        }

        // Tapped empty space — clear selection.
        highlightedEntity?.scale = [1, 1, 1]
        highlightedEntity = nil

        explorerViewModel.clearSelection()
        print("— Cleared selection (tapped empty space)")
    }

    /// Creates a ray (origin + direction) in world space from a screen tap location using the given camera.
    private func makeRayVectors(from point: CGPoint, viewSize: CGSize, camera: Entity) -> (origin: SIMD3<Float>, direction: SIMD3<Float>) {
        // Normalize tap to NDC (-1 to +1)
        let x = (Float(point.x) / Float(viewSize.width)) * 2 - 1
        let y = 1 - (Float(point.y) / Float(viewSize.height)) * 2   // flip Y

        // Approximate field of view (we can make this more precise later by reading the actual camera projection).
        let fov: Float = .pi / 3.0   // ~60 degrees
        let aspect = Float(viewSize.width / viewSize.height)
        let tanHalfFov = tan(fov / 2)

        // Direction in camera space
        var direction = SIMD3<Float>(
            x * tanHalfFov * aspect,
            y * tanHalfFov,
            -1.0
        )

        direction = simd_normalize(direction)

        // Transform direction into world space using the camera's orientation
        let worldDirection = camera.orientation.act(direction)
        let origin = camera.position

        return (origin: origin, direction: worldDirection)
    }
}

// MARK: - Temporary Component for Entity <-> Node mapping

/// Lightweight component we attach to RealityKit entities so we can
/// identify which logical MockCosmicNode they represent during hit testing.
struct MockNodeComponent: Component {
    let nodeId: String
}

// MARK: - Unsupported Fallback

private struct UnsupportedRealityKitView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundStyle(Theme.Colors.divineGold)

            Text("Cosmology Explorer Unavailable")
                .font(Theme.Fonts.heroTitle)
                .foregroundStyle(Theme.Colors.primaryText)

            Text(RealityKitSupport.unsupportedMessage)
                .font(Theme.Fonts.body)
                .foregroundStyle(Theme.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
    }
}

//#Preview {
//    CosmoScene()
//}
