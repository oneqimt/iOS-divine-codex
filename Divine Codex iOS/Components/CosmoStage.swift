//
//  CosmoStage.swift
//  Divine Codex iOS
//
//  Spatial, hierarchy-aware cosmology navigator. Replaces the flat carousel
//  with a drill-down hero stage: Monad → Pleroma → Aeon consort ring.
//
//  Wayfinding: tap the parent ghost orb or swipe from the leading edge to drill up.
//

import SwiftUI

struct CosmoStage: View {

    let viewModel: ExplorerViewModel
    var onSelectNode: (ExplorerNode) -> Void
    var onMonadReady: (() -> Void)? = nil

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ambientGlow(in: geo.size)

                switch viewModel.stageDepth {
                case .monad:
                    monadHero(in: geo.size)
                case .pleroma:
                    pleromaHero(in: geo.size)
                case .aeons:
                    aeonRing(in: geo.size)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .overlay(alignment: .top) {
            CosmoWayfindingLabel(title: viewModel.stageBreadcrumb)
                .padding(.top, 8)
        }
        .overlay(alignment: .bottom) {
            stageHint
                .padding(.bottom, 28)
        }
        .simultaneousGesture(stageDrillUpGesture)
        .animation(.spring(response: 0.55, dampingFraction: 0.82), value: viewModel.stageDepth)
    }

    // MARK: - Drill-up gesture

    private var stageDrillUpGesture: some Gesture {
        DragGesture(minimumDistance: 24)
            .onEnded { value in
                guard viewModel.stageDepth != .monad else { return }
                // Leading-edge back swipe (LTR): finger moves right.
                let isBackSwipe = value.translation.width > 70
                let isMostlyHorizontal = abs(value.translation.width) > abs(value.translation.height)
                if isBackSwipe && isMostlyHorizontal {
                    viewModel.drillUp()
                }
            }
    }

    // MARK: - Monad

    @ViewBuilder
    private func monadHero(in size: CGSize) -> some View {
        if let monad = viewModel.monad {
            let diameter = Self.heroDiameter(.monad, in: size)
            let tapAction: () -> Void = {
                if viewModel.pleroma != nil {
                    viewModel.drillToPleroma()
                } else {
                    onSelectNode(monad)
                }
            }
            let longPressAction: () -> Void = {
                viewModel.selectNode(monad)
                onSelectNode(monad)
            }

            SpinningCosmoOrbView(
                    node: monad,
                    diameter: diameter,
                    isEmphasized: true,
                    onTap: tapAction,
                    onLongPress: longPressAction,
                    onSceneReady: onMonadReady,
                    isStageVisible: viewModel.selectedNode == nil
                )
        } else {
            missingNodeMessage("Monad")
        }
    }

    // MARK: - Pleroma

    @ViewBuilder
    private func pleromaHero(in size: CGSize) -> some View {
        ZStack {
            if let monad = viewModel.monad {
                parentGhost(
                    node: monad,
                    diameter: Self.heroDiameter(.monad, in: size) * 0.55,
                    accessibilityLabel: "Return to \(monad.name)"
                )
            }

            if let pleroma = viewModel.pleroma {
                heroButton(node: pleroma, diameter: Self.heroDiameter(.pleroma, in: size)) {
                    if !viewModel.displayUnits.isEmpty {
                        viewModel.drillToAeons()
                    } else {
                        onSelectNode(pleroma)
                    }
                }
            } else {
                missingNodeMessage("Pleroma")
            }
        }
    }

    // MARK: - Aeons ring

    @ViewBuilder
    private func aeonRing(in size: CGSize) -> some View {
        let units = viewModel.displayUnits
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let ringRadius = min(size.width, size.height) * 0.34
        let tokenSize = min(size.width, size.height) * 0.11

        ZStack {
            if let pleroma = viewModel.pleroma {
                parentGhost(
                    node: pleroma,
                    diameter: tokenSize * 1.35,
                    accessibilityLabel: "Return to \(pleroma.name)"
                )
                .position(center)
            }

            if units.isEmpty {
                missingNodeMessage("Aeons")
            } else {
                ForEach(Array(units.enumerated()), id: \.element.id) { index, pair in
                    let angle = (2 * CGFloat.pi / CGFloat(units.count)) * CGFloat(index) - .pi / 2
                    let x = center.x + cos(angle) * ringRadius
                    let y = center.y + sin(angle) * ringRadius

                    pairToken(pair, diameter: tokenSize)
                        .position(x: x, y: y)
                        .zIndex(1)
                }
            }
        }
    }

    // MARK: - Parent ghost (tap to drill up)

    private func parentGhost(
        node: ExplorerNode,
        diameter: CGFloat,
        accessibilityLabel: String
    ) -> some View {
        Button {
            viewModel.drillUp()
        } label: {
            CosmoNodeOrb(node: node, diameter: diameter, showsLabel: false)
                .opacity(0.38)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    private func pairToken(_ pair: CosmoConsortPair, diameter: CGFloat) -> some View {
        let hitSide = max(diameter * 3.6, 96)
        let captionWidth = pair.consort == nil ? diameter + 44 : diameter * 2.8

        return Button {
            viewModel.selectPair(pair)
            onSelectNode(pair.primary)
        } label: {
            VStack(spacing: 8) {
                Group {
                    if let consort = pair.consort {
                        HStack(spacing: 6) {
                            CosmoNodeOrb(node: pair.primary, diameter: diameter, showsLabel: false)
                            CosmoNodeOrb(node: consort, diameter: diameter, showsLabel: false)
                        }
                    } else {
                        CosmoNodeOrb(node: pair.primary, diameter: diameter, isEmphasized: false, showsLabel: false)
                    }
                }

                CosmoOrbCaption(
                    title: pair.ringTitle,
                    shortDescription: pair.ringShortDescription,
                    maxWidth: captionWidth
                )
            }
        }
        .buttonStyle(.plain)
        .frame(minWidth: hitSide)
        .contentShape(Rectangle())
    }

    // MARK: - Shared hero

    private func heroButton(
        node: ExplorerNode,
        diameter: CGFloat,
        action: @escaping () -> Void
    ) -> some View {
        CosmoNodeOrb(node: node, diameter: diameter, isEmphasized: true)
            .contentShape(Circle())
            .onTapGesture(perform: action)
            .onLongPressGesture(minimumDuration: 0.45) {
                viewModel.selectNode(node)
                onSelectNode(node)
            }
    }

    private func ambientGlow(in size: CGSize) -> some View {
        RadialGradient(
            colors: [
                Theme.Colors.divineGold.opacity(0.12),
                Theme.Colors.accent.opacity(0.06),
                .clear
            ],
            center: .center,
            startRadius: 20,
            endRadius: max(size.width, size.height) * 0.55
        )
        .ignoresSafeArea()
    }

    private var stageHint: some View {
        Group {
            switch viewModel.stageDepth {
            case .monad:
                if viewModel.pleroma != nil {
                    hintLabel("Tap to enter · Long press for details")
                }
            case .pleroma:
                if !viewModel.displayUnits.isEmpty {
                    hintLabel("Tap to meet the Aeons · Swipe left to return · Long press for details")
                } else {
                    hintLabel("Swipe left to return")
                }
            case .aeons:
                hintLabel("Tap an emanation · Swipe left or tap center to return")
            }
        }
    }

    private func hintLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .foregroundStyle(Theme.Colors.tertiaryText)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
    }

    private func missingNodeMessage(_ name: String) -> some View {
        Text("\(name) not yet in Sanity")
            .font(.system(size: 15, weight: .medium, design: .rounded))
            .foregroundStyle(Theme.Colors.secondaryText)
    }

    // MARK: - Sizing

    static func heroDiameter(_ depth: CosmoStageDepth, in size: CGSize) -> CGFloat {
        let base = min(size.width, size.height)
        switch depth {
        case .monad: return base * 0.52
        case .pleroma: return base * 0.40
        case .aeons: return base * 0.28
        }
    }
}

#if DEBUG
#Preview {
    ZStack {
        Theme.Colors.background.ignoresSafeArea()
        CosmoStage(
            viewModel: {
                let vm = ExplorerViewModel()
                vm.updateWithServerData(Emanation.sampleSet)
                return vm
            }(),
            onSelectNode: { _ in }
        )
    }
}
#endif
