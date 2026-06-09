//
//  CosmoWayfindingLabel.swift
//  Divine Codex iOS
//
//  Faint breadcrumb for spatial navigation — tappable text, not a chrome button.
//

import SwiftUI

struct CosmoWayfindingLabel: View {

    let title: String
    var action: (() -> Void)?

    /// Minimum comfortable tap height (detail back breadcrumb, stage path).
    private let minTapHeight: CGFloat = 48

    var body: some View {
        Group {
            if let action {
                Button(action: action) {
                    labelContent
                }
                .buttonStyle(.plain)
            } else {
                labelContent
            }
        }
        .accessibilityLabel(title)
        .accessibilityHint(action != nil ? "Returns to the previous layer" : "")
        .accessibilityAddTraits(action != nil ? .isButton : [])
    }

    private var labelContent: some View {
        HStack(spacing: 6) {
            if action != nil {
                Image(systemName: "chevron.left")
                    .font(.system(size: 12, weight: .semibold))
            }
            Text(title)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .foregroundStyle(Theme.Colors.tertiaryText)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, minHeight: minTapHeight, alignment: .leading)
        .contentShape(Rectangle())
    }
}