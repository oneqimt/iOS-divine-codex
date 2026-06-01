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

    // MARK: - Default Camera

    private let defaultCameraPosition = SIMD3<Float>(0, 11, 30)
    private let defaultCameraLookAt = SIMD3<Float>(0, 9, 0)

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

                                    // Create entities from the modern data model
                                    var entityMap: [String: Entity] = [:]

                                    for node in explorerViewModel.nodes {
                                        if let entity = makeEntity(for: node) {
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
                                        animateCameraStep(camera: camera)
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

                                // 2D Node Labels (overlay)
                                ForEach(Array(labelScreenPositions.keys), id: \.self) { id in
                                    if let pos = labelScreenPositions[id],
                                       let node = explorerViewModel.nodes.first(where: { $0.id == id }) {
                                        NodeLabelView(title: node.name)
                                            .position(pos)
                                    }
                                }
                            }
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
            print("Sanity codices count: \(sanity.codices.count)")
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

    private func makeEntity(for node: ExplorerNode) -> Entity? {
        guard let visuals = node.explorer else { return nil }

        let radius: Float = (visuals.scale ?? 1.0) * 0.5

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
        entity.position = visuals.worldPosition

        entity.components.set(NodeIdentifierComponent(nodeId: node.id))
        entity.components.set(CollisionComponent(shapes: [.generateSphere(radius: radius * 1.25)]))

        return entity
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
        guard let visuals = node.explorer else { return }

        let focusDistance: Float = 18.0
        let cameraHeight: Float = 11.5
        let lookAtLift: Float = 1.8

        let targetPosition = SIMD3<Float>(
            visuals.worldPosition.x,
            cameraHeight,
            visuals.worldPosition.z + focusDistance
        )
        let targetLookAt = visuals.worldPosition + SIMD3<Float>(0, lookAtLift, 0)

        cameraTargetPosition = targetPosition
        cameraTargetLookAt = targetLookAt
        isCameraAnimating = true
    }

    private func returnToOverview() {
        cameraTargetPosition = defaultCameraPosition
        cameraTargetLookAt = defaultCameraLookAt
        isCameraAnimating = true
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

    private func resetCameraAndHighlightState() {
        cameraTargetPosition = nil
        cameraTargetLookAt = nil
        isCameraAnimating = false
        hasReceivedInitialSelectionChange = false
        highlightedEntity = nil
        targetHighlightScale = 1.0
        labelScreenPositions = [:]

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
                  node.explorer != nil else { continue }

            if let screenPos = worldToScreen(entity.position, camera: camera, viewSize: viewSize) {
                newPositions[id] = CGPoint(x: screenPos.x, y: screenPos.y - 52)
            }
        }

        DispatchQueue.main.async {
            self.labelScreenPositions = newPositions
        }
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
