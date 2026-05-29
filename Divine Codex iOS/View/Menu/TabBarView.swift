//
//  TabBarView.swift
//  Divine Codex iOS
//
//  Custom Liquid Glass tab bar. Owns no navigation state itself —
//  it just reads/writes a `MainTab` binding so parents stay in control.
//
//  Created by Dennis Miller on 5/29/26.
//

import SwiftUI

struct TabBarView: View {
    @Binding var selectedTab: MainTab
    @Namespace private var glassNamespace

    var body: some View {
        GlassEffectContainer(spacing: 8) {
            HStack(spacing: 8) {
                ForEach(MainTab.allCases, id: \.self) { tab in
                    tabButton(for: tab)
                }
            }
            .padding(6)
            // 1) Solid translucent black sits *under* the glass.
            // 2) The glass capsule refracts on top, keeping the highlights
            //    but no longer reading as neutral gray.
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.85 ))
            )
            .glassEffect(.regular, in: .capsule)
        }
        .padding(.horizontal, Theme.Spacing.md)
    }

    @ViewBuilder
    private func tabButton(for tab: MainTab) -> some View {
        let isSelected = (tab == selectedTab)

        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 2) {
                Image(systemName: tab.iconName)
                    .font(.system(size: 18, weight: .medium))
                Text(tab.title)
                    .font(Theme.Fonts.caption)
            }
            .foregroundStyle(
                isSelected ? Theme.Colors.primaryText : Theme.Colors.tertiaryText
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .background {
            if isSelected {
                Capsule()
                    .fill(.clear)
                    .glassEffect(
                        .regular.tint(Theme.Colors.accent.opacity(0.75)).interactive(),
                        in: .capsule
                    )
                    .matchedGeometryEffect(id: "selectedTab", in: glassNamespace)
            }
        }
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    @Previewable @State var tab: MainTab = .home
    return ZStack {
        Theme.Colors.background.ignoresSafeArea()
        VStack {
            Spacer()
            TabBarView(selectedTab: $tab)
                .padding(.bottom, 16)
        }
    }
}
