//
//  CosmoScene.swift
//  Divine Codex iOS
//
//  The full-screen immersive RealityKit Cosmology Explorer.
//
//  Clean reconstruction that preserves the working OLD structure
//  while integrating the new architecture (ExplorerViewModel, ExplorerNode,
//  NodeLabelView, camera focus system, and single-node highlight logic).
//

import SwiftUI
import RealityKit
import simd

struct CosmoScene: View {

    // MARK: - Dependencies

    let explorerViewModel: ExplorerViewModel
    @Environment(SanityViewModel.self) private var sanity
    @Environment(\.dismiss) private var dismiss

    // MARK: - RealityKit References

    @State private var rootEntity: Entity?
    @State private var cameraEntity: Entity?

    // MARK: - Camera Focus System

    @State private var cameraTargetPosition: SIMD3<Float>?
    @State private var cameraTargetLookAt: SIMD3<Float>?
    @State private var isCameraAnimating = false
    @State private var hasReceivedInitialSelectionChange = false

    // MARK: - Visual Emphasis (Single Node Highlight)

    @State private var highlightedEntity: Entity?
    @State private var targetHighlightScale: Float = 1.0

    // MARK: - 2D Label Overlay (for node titles)

    @State private var labelScreenPositions: [String: CGPoint] = [:]

    /// Entities created in the 3D scene, keyed by node id.
    @State private var nodeEntities: [String: Entity] = [:]

    /// Holds the subscription to SceneEvents.Update so it isn't immediately cancelled.
    @State private var sceneUpdateSubscription: EventSubscription?

    // MARK: - Manual Camera Panning / Orbit / Dolly

    @State private var isUserPanning = false
    @State private var accumulatedYaw: Float = 0
    @State private var accumulatedPitch: Float = 0
    @State private var orbitDistance: Float = 38
    @State private var lastDragTranslation: CGSize = .zero
    @State private var lastMagnification: CGFloat = 1.0
    @State private var userOrbitPivot: SIMD3<Float> = .zero

    // MARK: - Layout Source

    /// While cosmology positions are still being authored in Sanity, set this to
    /// `false` to ignore Sanity's `explorer.position` and use the computed
    /// fallback layout (Monad → Pleroma → Aeon ring) for every node. Flip back
    /// to `true` once real coordinates have been entered in Sanity.
    private let usesSanityPositions = false

    // MARK: - Default Camera

    // Framed so the centered Monad → Pleroma → Aeon-ring layout sits in the
    // middle of the viewport. Look-at targets the vertical center of the
    // arrangement; the camera is pulled back enough to fit the wide Aeon ring.
    private let defaultCameraPosition = SIMD3<Float>(0, 8, 38)
    private let defaultCameraLookAt = SIMD3<Float>(0, 8, 0)

    // === TUNING KNOBS for compact 3D node labels (initial state) ===
    // These control the vertical "top padding" / space above the label relative to the 3D sphere center.
    // Larger nodes (higher explorer.scale) get more lift via the scale factor.
    // Lower the values to tighten (less space above the label on large nodes).
    // The offset is used as y += verticalOffset (negative = higher on screen).
    private let label3DOffsetScaleFactor: CGFloat = 28  // TUNING KNOB - lower to tighten top space on large nodes
    private let label3DOffsetBase: CGFloat = 5          // TUNING KNOB - base for scale=1
    // Additional knob in NodeLabelView.swift: the ? 4 in .padding(.vertical, useStronger... ? 4 : 3)
    // Increase the 4 for more internal top/bottom padding on the text itself in 3D compact.

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                Color.black.ignoresSafeArea()

                Group {
                    if RealityKitSupport.isSupported {
                        GeometryReader { geometry in
                            ZStack {
                                RealityView { content in
                                    let root = Entity()
                                    root.name = "CosmologyRoot"

                                    // Basic lighting
                                    let light = DirectionalLight()
                                    light.light.intensity = 1400
                                    light.position = [0, 12, 0]
                                    root.addChild(light)

                                    // Create entities from the modern data model.
                                    // Aeons are spread evenly in a ring as a layout
                                    // fallback, so pre-compute each Aeon's index.
                                    var entityMap: [String: Entity] = [:]

                                    let aeonNodes = explorerViewModel.nodes.filter {
                                        $0.emanationType == "aeon"
                                    }
                                    let aeonCount = aeonNodes.count

                                    for node in explorerViewModel.nodes {
                                        let aeonIndex = aeonNodes.firstIndex(where: { $0.id == node.id })
                                        if let entity = makeEntity(for: node,
                                                                   aeonIndex: aeonIndex,
                                                                   aeonCount: aeonCount) {
                                            root.addChild(entity)
                                            entityMap[node.id] = entity
                                        }
                                    }

                                    content.add(root)

                                    // Camera
                                    let camera = PerspectiveCamera()
                                    camera.position = defaultCameraPosition
                                    camera.look(at: defaultCameraLookAt,
                                                from: defaultCameraPosition,
                                                relativeTo: nil)
                                    content.add(camera)

                                    // Animation + highlight + label positioning loop
                                    // Store the subscription so it isn't deallocated immediately.
                                    sceneUpdateSubscription = content.subscribe(to: SceneEvents.Update.self) { _ in
                                        if isUserPanning {
                                            applyUserOrbit(camera: camera)
                                        } else {
                                            animateCameraStep(camera: camera)
                                        }
                                        animateHighlight()
                                        updateLabelScreenPositions(camera: camera, viewSize: geometry.size)
                                    }

                                    DispatchQueue.main.async {
                                        rootEntity = root
                                        cameraEntity = camera
                                        nodeEntities = entityMap
                                    }
                                }
                                .gesture(
                                    SpatialTapGesture()
                                        .onEnded { value in
                                            let tapLocation = value.location
                                            handleTap(at: tapLocation, in: geometry.size)
                                        }
                                )

                                // 2D Node representations (overlay) - using ExplorerNodeButton
                                // so the same component can tween to detail state.
                                // In 3D, the "label" at the node's screen pos is the button, which
                                // becomes the detail card when selected (original node visual becomes the detail).
                                // These stay correctly pinned during manual panning because
                                // updateLabelScreenPositions runs every frame against the live camera.
                                ForEach(Array(labelScreenPositions.keys), id: \.self) { id in
                                    if let pos = labelScreenPositions[id],
                                       let node = explorerViewModel.nodes.first(where: { $0.id == id }) {
                                        ExplorerNodeButton(
                                            node: node,
                                            isSelected: explorerViewModel.selectedNode?.id == id,
                                            action: {
                                                if explorerViewModel.selectedNode?.id == node.id {
                                                    explorerViewModel.clearSelection()
                                                } else {
                                                    explorerViewModel.selectNode(node)
                                                }
                                            },
                                            useStrongerBackgroundFor3DCompact: true
                                        )
                                        .position(pos)
                                    }
                                }
                            }
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 10)
                                    .onChanged { value in
                                        if !isUserPanning {
                                            isUserPanning = true
                                            isCameraAnimating = false

                                            if let cam = cameraEntity {
                                                let pivot = cameraTargetLookAt ?? defaultCameraLookAt
                                                userOrbitPivot = pivot
                                                let vec = cam.position - pivot
                                                orbitDistance = simd_length(vec)
                                                accumulatedYaw = atan2(vec.x, vec.z)
                                                accumulatedPitch = asin(vec.y / max(orbitDistance, 0.001))
                                            }
                                            lastDragTranslation = value.translation
                                        }

                                        let sensitivity: Float = 0.004
                                        let delta = CGSize(
                                            width: value.translation.width - lastDragTranslation.width,
                                            height: value.translation.height - lastDragTranslation.height
                                        )
                                        accumulatedYaw += Float(delta.width) * sensitivity
                                        accumulatedPitch += Float(delta.height) * sensitivity
                                        accumulatedPitch = max(-Float.pi / 2 + 0.05, min(Float.pi / 2 - 0.05, accumulatedPitch))
                                        lastDragTranslation = value.translation
                                    }
                                    .onEnded { _ in
                                        lastDragTranslation = .zero
                                    }
                            )
                            .simultaneousGesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        if !isUserPanning {
                                            isUserPanning = true
                                            isCameraAnimating = false
                                            if let cam = cameraEntity {
                                                let pivot = cameraTargetLookAt ?? defaultCameraLookAt
                                                userOrbitPivot = pivot
                                                let vec = cam.position - pivot
                                                orbitDistance = simd_length(vec)
                                                accumulatedYaw = atan2(vec.x, vec.z)
                                                accumulatedPitch = asin(vec.y / max(orbitDistance, 0.001))
                                            }
                                            lastMagnification = 1.0
                                        }
                                        let deltaScale = value / lastMagnification
                                        if deltaScale != 0 {
                                            orbitDistance = orbitDistance / Float(deltaScale)
                                        }
                                        orbitDistance = max(5.0, min(120.0, orbitDistance))
                                        lastMagnification = value
                                    }
                                    .onEnded { _ in
                                        lastMagnification = 1.0
                                    }
                            )
                        }
                    } else {
                        UnsupportedRealityKitView()
                    }
                }
            }
            .ignoresSafeArea()

            // Dismiss button
            closeButton
                .padding(.top, 8)
                .padding(.trailing, 20)
                .safeAreaPadding(.top)
        }
        .onAppear {
            explorerViewModel.didEnterImmersiveScene()
            print("Sanity emanations count: \(sanity.emanations.count)")
            print("ExplorerViewModel nodes count: \(explorerViewModel.nodes.count)")
        }
        .onDisappear {
            explorerViewModel.didExitImmersiveScene()
            resetCameraAndHighlightState()
        }
        .onChange(of: explorerViewModel.selectedNode) { oldValue, newNode in
            if !hasReceivedInitialSelectionChange {
                hasReceivedInitialSelectionChange = true
                if oldValue == nil && newNode == nil { return }
            }

            if let node = newNode {
                focusOnNode(node)
            } else {
                returnToOverview()
            }
            updateHighlight(for: newNode)
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

    // MARK: - Entity Creation (updated for new data model)

    /// Builds a node entity.
    ///
    /// Position and scale come from Sanity (`explorer`) when available. When
    /// `explorer.position` is missing, we fall back to a sensible layout based
    /// on emanation type so the nodes don't all stack at the origin:
    ///   - Monad sits at the top of the cosmos
    ///   - Pleroma sits just below it
    ///   - Aeons spread evenly around a ring beneath the Pleroma
    private func makeEntity(for node: ExplorerNode,
                            aeonIndex: Int?,
                            aeonCount: Int) -> Entity? {
        guard let visuals = node.explorer else { return nil }

        // Size is driven by emanation type for now (Sanity `scale` is honored
        // when present). Clear hierarchy: Monad largest, then Pleroma, then the
        // Aeons all equal and smaller.
        let radius: Float = nodeRadius(for: node, visuals: visuals)

        let mesh: MeshResource = switch visuals.geometryHint {
        case "sphere", "light": .generateSphere(radius: radius)
        case "octahedron":      .generateBox(size: radius * 1.4)
        default:                .generateSphere(radius: radius)
        }

        let material = SimpleMaterial(
            color: colorFromHex(visuals.colorHex) ?? .white,
            isMetallic: false
        )

        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.name = node.id

        // Prefer an explicit Sanity position only when `usesSanityPositions` is
        // enabled AND the value is "real" (non-origin). While positions are
        // still being authored, `usesSanityPositions` is false so every node
        // uses the computed fallback layout — otherwise the placeholder Sanity
        // coordinates cluster the nodes into the "molecule" look.
        if usesSanityPositions,
           let position = visuals.position,
           simd_length(position) > 0.01 {
            entity.position = position
        } else {
            entity.position = fallbackPosition(for: node,
                                               aeonIndex: aeonIndex,
                                               aeonCount: aeonCount)
        }

        #if DEBUG
        print("🌐 \(node.name) [\(node.emanationType ?? "?")] → pos \(entity.position), r \(radius), sanityPos \(String(describing: visuals.position))")
        #endif

        entity.components.set(NodeIdentifierComponent(nodeId: node.id))
        entity.components.set(CollisionComponent(shapes: [.generateSphere(radius: radius * 1.25)]))

        return entity
    }

    /// A layout used when a node has no explicit `explorer.position` in Sanity.
    /// Centers the arrangement vertically around the camera's look-at height so
    /// the whole cosmology sits in the middle of the viewport, with generous
    /// spacing between layers.
    ///
    /// Layout (top → bottom): Monad, Pleroma, then a wide ring of Aeons.
    private func fallbackPosition(for node: ExplorerNode,
                                  aeonIndex: Int?,
                                  aeonCount: Int) -> SIMD3<Float> {
        // Vertical center of the arrangement. Matches the camera look-at so the
        // scene is framed in the middle of the viewport.
        let centerY = layoutCenterY

        switch node.emanationType {
        case "monad":
            // Highest node, sitting above center.
            return SIMD3<Float>(0, centerY + 9, 0)
        case "pleroma":
            // Just below the Monad.
            return SIMD3<Float>(0, centerY + 3, 0)
        case "aeon":
            // Spread Aeons evenly around a wide horizontal ring below center.
            // A half-step phase offset keeps the first node off the exact
            // camera axis, and a gentle vertical stagger prevents the ring from
            // ever collapsing into a single cluster when viewed near edge-on.
            let count = max(aeonCount, 1)
            let index = aeonIndex ?? 0
            let phase = Float(index) / Float(count)
            let angle = phase * 2 * .pi + (.pi / Float(count))
            let ringRadius: Float = 14.0
            let verticalStagger: Float = (index % 2 == 0) ? 1.0 : -1.0
            return SIMD3<Float>(
                ringRadius * cos(angle),
                centerY - 5 + verticalStagger,
                ringRadius * sin(angle)
            )
        default:
            return SIMD3<Float>(0, centerY, 0)
        }
    }

    /// The vertical center of the cosmology layout. The camera looks here and
    /// the Monad/Pleroma/Aeons are arranged around it, keeping everything
    /// centered in the viewport.
    private var layoutCenterY: Float { 6 }

    /// Radius for a node's primitive. Honors Sanity `scale` when present;
    /// otherwise uses a type-based hierarchy: Monad largest, Pleroma next, and
    /// all Aeons equal and smaller.
    private func nodeRadius(for node: ExplorerNode, visuals: ExplorerVisuals) -> Float {
        if let scale = visuals.scale {
            return scale * 1.2
        }
        switch node.emanationType {
        case "monad":   return 3.0
        case "pleroma": return 2.2
        case "aeon":    return 1.4
        default:        return 1.4
        }
    }

    private func colorFromHex(_ hex: String?) -> UIColor? {
        guard let hex = hex else { return nil }
        let hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }

    // MARK: - Camera Focus System

    private func focusOnNode(_ node: ExplorerNode) {
        // Use the entity's actual scene position (which may be a layout
        // fallback) rather than `visuals.worldPosition`, so focusing works even
        // when Sanity has no explicit position yet.
        guard let entity = nodeEntities[node.id] else { return }
        let nodePosition = entity.position

        let focusDistance: Float = 18.0
        let cameraHeight: Float = 11.5
        let lookAtLift: Float = 1.8

        let targetPosition = SIMD3<Float>(
            nodePosition.x,
            cameraHeight,
            nodePosition.z + focusDistance
        )
        let targetLookAt = nodePosition + SIMD3<Float>(0, lookAtLift, 0)

        cameraTargetPosition = targetPosition
        cameraTargetLookAt = targetLookAt
        isCameraAnimating = true
        isUserPanning = false   // scripted focus takes precedence
    }

    private func returnToOverview() {
        cameraTargetPosition = defaultCameraPosition
        cameraTargetLookAt = defaultCameraLookAt
        isCameraAnimating = true
        isUserPanning = false
    }

    private func animateCameraStep(camera: Entity) {
        guard isCameraAnimating,
              let targetPos = cameraTargetPosition,
              let targetLook = cameraTargetLookAt else { return }

        let currentPos = camera.position
        let distance = simd_length(targetPos - currentPos)

        if distance < 0.15 {
            isCameraAnimating = false
            return
        }

        let damping: Float = 0.075
        let newPos = simd_mix(currentPos, targetPos, SIMD3<Float>(repeating: damping))
        camera.position = newPos
        camera.look(at: targetLook, from: newPos, relativeTo: nil)
    }

    private func applyUserOrbit(camera: Entity) {
        guard isUserPanning else { return }

        let pitch = accumulatedPitch
        let yaw = accumulatedYaw
        let distance = orbitDistance

        let x = distance * cos(pitch) * sin(yaw)
        let y = distance * sin(pitch)
        let z = distance * cos(pitch) * cos(yaw)

        camera.position = userOrbitPivot + SIMD3<Float>(x, y, z)
        camera.look(at: userOrbitPivot, from: camera.position, relativeTo: nil)
    }

    private func resetCameraAndHighlightState() {
        cameraTargetPosition = nil
        cameraTargetLookAt = nil
        isCameraAnimating = false
        hasReceivedInitialSelectionChange = false
        highlightedEntity = nil
        targetHighlightScale = 1.0
        labelScreenPositions = [:]

        isUserPanning = false
        accumulatedYaw = 0
        accumulatedPitch = 0
        orbitDistance = 38
        lastDragTranslation = .zero
        lastMagnification = 1.0

        for entity in nodeEntities.values {
            entity.scale = [1, 1, 1]
        }

        // Cancel the recurring SceneEvents.Update subscription
        sceneUpdateSubscription?.cancel()
        sceneUpdateSubscription = nil
    }

    // MARK: - Visual Emphasis (Single Node)

    private func updateHighlight(for node: ExplorerNode?) {
        if let old = highlightedEntity {
            old.scale = [1, 1, 1]
        }

        guard let node = node,
              let entity = nodeEntities[node.id] else {
            highlightedEntity = nil
            targetHighlightScale = 1.0
            return
        }

        highlightedEntity = entity
        targetHighlightScale = 1.65
    }

    private func animateHighlight() {
        guard let entity = highlightedEntity else { return }
        let current = entity.scale.x
        let newScale = simd_mix(current, targetHighlightScale, 0.12)
        entity.scale = SIMD3<Float>(repeating: newScale)

        if targetHighlightScale == 1.0 && abs(newScale - 1.0) < 0.01 {
            highlightedEntity = nil
        }
    }

    // MARK: - 2D Label Projection (Overlay)

    private func updateLabelScreenPositions(camera: Entity, viewSize: CGSize) {
        var newPositions: [String: CGPoint] = [:]

        for (id, entity) in nodeEntities {
            guard let node = explorerViewModel.nodes.first(where: { $0.id == id }),
                  let visuals = node.explorer else { continue }

            if let screenPos = worldToScreen(entity.position, camera: camera, viewSize: viewSize) {
                // Lift the label proportionally to the node's actual radius so it
                // clears larger nodes (Monad/Pleroma) even when Sanity `scale`
                // is absent and the size comes from the type-based fallback.
                let effectiveScale = visuals.scale ?? nodeRadius(for: node, visuals: visuals)
                let verticalOffset: CGFloat = -(CGFloat(effectiveScale) * label3DOffsetScaleFactor + label3DOffsetBase)
                newPositions[id] = CGPoint(x: screenPos.x, y: screenPos.y + verticalOffset)
            }
        }

        // Direct assignment (subscription callback is delivered on main).
        // This gives tighter following for the 2D cards/labels when the user is manually panning/orbiting.
        self.labelScreenPositions = newPositions
    }

    private func worldToScreen(_ worldPosition: SIMD3<Float>, camera: Entity, viewSize: CGSize) -> CGPoint? {
        let cameraPos = camera.position
        let toPoint = worldPosition - cameraPos
        let local = camera.orientation.inverse.act(toPoint)
        guard local.z < 0 else { return nil }

        let fov: Float = .pi / 3.0
        let aspect = Float(viewSize.width / viewSize.height)
        let tanHalfFov = tan(fov / 2)

        let x = (local.x / (-local.z)) / (tanHalfFov * aspect)
        let y = (local.y / (-local.z)) / tanHalfFov

        let screenX = (x + 1) * 0.5 * Float(viewSize.width)
        let screenY = (1 - y) * 0.5 * Float(viewSize.height)
        return CGPoint(x: CGFloat(screenX), y: CGFloat(screenY))
    }

    // MARK: - Hit Testing

    private func handleTap(at location: CGPoint, in viewSize: CGSize) {
        guard let root = rootEntity, let camera = cameraEntity else { return }

        let (origin, direction) = makeRayVectors(from: location, viewSize: viewSize, camera: camera)
        guard let scene = root.scene else { return }

        let hits = scene.raycast(origin: origin, direction: direction, length: 1000, query: .nearest)

        for hit in hits {
            if let component = hit.entity.components[NodeIdentifierComponent.self],
               let node = explorerViewModel.nodes.first(where: { $0.id == component.nodeId }) {

                if explorerViewModel.selectedNode?.id == node.id {
                    explorerViewModel.clearSelection()
                } else {
                    explorerViewModel.selectNode(node)
                }
                return
            }
        }

        explorerViewModel.clearSelection()
    }

    private func makeRayVectors(from point: CGPoint, viewSize: CGSize, camera: Entity) -> (origin: SIMD3<Float>, direction: SIMD3<Float>) {
        let x = (Float(point.x) / Float(viewSize.width)) * 2 - 1
        let y = 1 - (Float(point.y) / Float(viewSize.height)) * 2
        let fov: Float = .pi / 3.0
        let aspect = Float(viewSize.width / viewSize.height)
        let tanHalfFov = tan(fov / 2)

        var dir = SIMD3<Float>(x * tanHalfFov * aspect, y * tanHalfFov, -1.0)
        dir = simd_normalize(dir)
        let worldDir = camera.orientation.act(dir)
        return (camera.position, worldDir)
    }
}

// MARK: - Supporting Types

struct NodeIdentifierComponent: Component {
    let nodeId: String
}

private struct UnsupportedRealityKitView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundStyle(Theme.Colors.divineGold)
            Text("Cosmology Explorer Unavailable")
                .font(Theme.Fonts.heroTitle)
            Text(RealityKitSupport.unsupportedMessage)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
    }
}
