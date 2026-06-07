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
    }

    private var labelContent: some View {
        HStack(spacing: 4) {
            if action != nil {
                Image(systemName: "chevron.left")
                    .font(.system(size: 11, weight: .semibold))
            }
            Text(title)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .foregroundStyle(Theme.Colors.tertiaryText)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }
}