//
//  CosmoStage.swift
//  Divine Codex iOS
//
//  Spatial, hierarchy-aware cosmology navigator. Replaces the flat carousel
//  with a drill-down hero stage: Monad → Pleroma → Aeon consort ring.
//

import SwiftUI

struct CosmoStage: View {

    let viewModel: ExplorerViewModel
    var onSelectNode: (ExplorerNode) -> Void

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
        .overlay(alignment: .topLeading) {
            if viewModel.stageDepth != .monad {
                backButton
                    .padding(16)
            }
        }
        .overlay(alignment: .bottom) {
            stageHint
                .padding(.bottom, 28)
        }
        .animation(.spring(response: 0.55, dampingFraction: 0.82), value: viewModel.stageDepth)
    }

    // MARK: - Monad

    @ViewBuilder
    private func monadHero(in size: CGSize) -> some View {
        if let monad = viewModel.monad {
            heroButton(node: monad, diameter: Self.heroDiameter(.monad, in: size)) {
                if viewModel.pleroma != nil {
                    viewModel.drillToPleroma()
                } else {
                    onSelectNode(monad)
                }
            }
        } else {
            missingNodeMessage("Monad")
        }
    }

    // MARK: - Pleroma

    @ViewBuilder
    private func pleromaHero(in size: CGSize) -> some View {
        ZStack {
            if let monad = viewModel.monad {
                CosmoNodeOrb(node: monad, diameter: Self.heroDiameter(.monad, in: size) * 0.55, showsLabel: false)
                    .opacity(0.22)
                    .blur(radius: 1)
                    .allowsHitTesting(false)
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
                CosmoNodeOrb(node: pleroma, diameter: tokenSize * 1.35, showsLabel: false)
                    .opacity(0.35)
                    .position(center)
                    .allowsHitTesting(false)
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
                }
            }
        }
    }

    private func pairToken(_ pair: CosmoConsortPair, diameter: CGFloat) -> some View {
        Button {
            viewModel.selectPair(pair)
            onSelectNode(pair.primary)
        } label: {
            if let consort = pair.consort {
                HStack(spacing: 6) {
                    CosmoNodeOrb(node: pair.primary, diameter: diameter, showsLabel: false)
                    CosmoNodeOrb(node: consort, diameter: diameter, showsLabel: false)
                }
                .overlay(alignment: .bottom) {
                    Text(pair.displayName)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.Colors.primaryText.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(width: diameter * 2.8)
                        .offset(y: diameter * 0.75)
                }
            } else {
                CosmoNodeOrb(node: pair.primary, diameter: diameter, isEmphasized: false)
            }
        }
        .buttonStyle(.plain)
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
                    hintLabel("Tap to enter · Hold for details")
                }
            case .pleroma:
                if !viewModel.displayUnits.isEmpty {
                    hintLabel("Tap to meet the Aeons · Hold for details")
                }
            case .aeons:
                hintLabel("Tap an emanation to explore")
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

    private var backButton: some View {
        Button {
            viewModel.drillUp()
        } label: {
            Label("Back", systemImage: "chevron.left")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.Colors.primaryText.opacity(0.9))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Go back")
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