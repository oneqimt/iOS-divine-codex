//
//  CosmoSidebar.swift
//  Divine Codex iOS
//
//  A 2D, data-bound detail pane for the Cosmology Explorer. Shown alongside
//  the platter carousel (as the detail column of a NavigationSplitView on
//  iPad, or as a slide-over overlay on iPhone). Updates whenever the user
//  selects a different node in the carousel.
//
//  Unlike the old NodeDetailView (a compact 3D overlay card), this is a full
//  scrollable surface intended to hold rich content: long-form Portable Text,
//  images, and video.
//

import SwiftUI
import AVKit

struct CosmoSidebar: View {

    /// The node to display. When `nil`, a gentle empty state is shown.
    let node: ExplorerNode?

    /// Called when the user taps the close control.
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()

            if let node {
                content(for: node)
            } else {
                emptyState
            }
        }
    }

    // MARK: - Content

    private func content(for node: ExplorerNode) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header(for: node)

                if let shortDescription = node.shortDescription {
                    Text(shortDescription)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(Theme.Colors.primaryText.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }

                // MARK: Rich body (Portable Text)
                //
                // Drop your existing PortableTextBlock renderer in here. The
                // blocks live on the underlying Emanation:
                //
                //   if case let .emanation(e) = node, let blocks = e.description {
                //       PortableTextView(blocks: blocks)
                //   }
                //
                // Left as a placeholder for now so this compiles without the
                // renderer wired up.
                bodyPlaceholder(for: node)

                // MARK: Media
                mediaSection(for: node)

                Spacer(minLength: 24)
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .overlay(alignment: .topTrailing) {
            closeButton
                .padding(16)
        }
    }

    private func header(for node: ExplorerNode) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if let type = node.emanationType {
                Text(type.capitalized)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.Colors.divineGold)
                    .textCase(.uppercase)
                    .tracking(1.2)
            }

            Text(node.name)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.Colors.primaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        // Leave room so the title never sits under the close button.
        .padding(.trailing, 40)
    }

    @ViewBuilder
    private func bodyPlaceholder(for node: ExplorerNode) -> some View {
        if case let .emanation(emanation) = node,
           emanation.description != nil {
            // TODO: Replace with your PortableTextBlock renderer.
            Text("Rich detail content goes here.")
                .font(.system(size: 15))
                .foregroundStyle(Theme.Colors.primaryText.opacity(0.6))
                .italic()
        }
    }

    @ViewBuilder
    private func mediaSection(for node: ExplorerNode) -> some View {
        if case let .emanation(emanation) = node {
            if let video = emanation.video,
               let urlString = video.url,
               let url = URL(string: urlString) {
                VideoPlayer(player: AVPlayer(url: url))
                    .aspectRatio(16.0 / 9.0, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            // Image gallery placeholder — wire to your asset/image loader.
            if let media = emanation.media, !media.isEmpty {
                Text("\(media.count) image\(media.count == 1 ? "" : "s")")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.Colors.primaryText.opacity(0.5))
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundStyle(Theme.Colors.divineGold.opacity(0.7))
            Text("Select a node")
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.Colors.primaryText.opacity(0.7))
            Text("Choose an emanation from the platter to explore its details.")
                .font(.system(size: 14))
                .foregroundStyle(Theme.Colors.primaryText.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    // MARK: - Close Button

    private var closeButton: some View {
        Button(action: onClose) {
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
        .buttonStyle(.plain)
        .accessibilityLabel("Close details")
    }
}

// MARK: - Preview

#if DEBUG
#Preview("With node") {
    CosmoSidebar(
        node: .emanation(.sample()),
        onClose: {}
    )
}

#Preview("Empty") {
    CosmoSidebar(node: nil, onClose: {})
}
#endif
