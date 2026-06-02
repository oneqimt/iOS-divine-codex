//
//  NodeLabelView.swift
//  Divine Codex iOS
//
//  A reusable label component for displaying node titles.
//  Designed to work in both 2D UI (ExplorerNodeButton) and as
//  billboarded attachments inside the 3D RealityView scene.
//

import SwiftUI

struct NodeLabelView: View {
    let title: String
    var isEmphasized: Bool = false
    var useStrongerBackgroundFor3D: Bool = false  // for compact labels in the 3D scene overlay

    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundStyle(Theme.Colors.primaryText)
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, useStrongerBackgroundFor3D && !isEmphasized ? 4 : 3)  // TUNING KNOB for 3D compact label internal top/bottom padding (the ? value); increase if label text needs more space on large nodes
            .background(
                Group {
                    if useStrongerBackgroundFor3D && !isEmphasized {
                        Capsule()
                            .fill(Color.black.opacity(0.7))
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )
                    } else {
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(
                                        isEmphasized
                                            ? Theme.Colors.divineGold.opacity(0.45)
                                            : Color.white.opacity(0.12),
                                        lineWidth: isEmphasized ? 1.5 : 1
                                    )
                            )
                    }
                }
            )
            .scaleEffect(isEmphasized ? 1.08 : 1.0)
            .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 1)
            .animation(.easeInOut(duration: 0.2), value: isEmphasized)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        NodeLabelView(title: "Monad")
        NodeLabelView(title: "Pleroma", isEmphasized: true)
        NodeLabelView(title: "Aeon")
    }
    .padding()
    .background(Theme.Colors.background)
}
