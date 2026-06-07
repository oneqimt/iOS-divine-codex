//
//  CosmoDetailView.swift
//  Divine Codex iOS
//
//  Full-screen detail for a selected emanation (or consort pair). Migrated from
//  the split-view sidebar so rich content uses the entire viewport.
//
//  Wayfinding: swipe from the leading edge to return; faint breadcrumb is optional tap target.
//

import SwiftUI
import AVKit

struct CosmoDetailView: View {

    let pair: CosmoConsortPair
    let returnLabel: String
    var onBack: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            Theme.Colors.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    ForEach(pair.members, id: \.id) { node in
                        memberSection(for: node, showsPairHeader: pair.members.count > 1)
                    }
                    Spacer(minLength: 32)
                }
                .padding(24)
                .padding(.top, 36)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            CosmoWayfindingLabel(title: returnLabel, action: onBack)
                .padding(.top, 8)
                .padding(.leading, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Member content

    private func memberSection(for node: ExplorerNode, showsPairHeader: Bool) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            if showsPairHeader {
                Divider()
                    .overlay(Theme.Colors.primaryText.opacity(0.15))
            }

            header(for: node)

            if let shortDescription = node.shortDescription {
                Text(shortDescription)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Theme.Colors.primaryText.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }

            bodySection(for: node)
            mediaSection(for: node)
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
    }

    @ViewBuilder
    private func bodySection(for node: ExplorerNode) -> some View {
        if case let .emanation(emanation) = node,
           let blocks = emanation.description,
           !blocks.isEmpty {
            PortableTextView(blocks: blocks, textFont: .body)
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

            if let media = emanation.media, !media.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(media.enumerated()), id: \.offset) { _, item in
                        mediaImage(item)
                    }
                }
            }
        }
    }

    private func mediaImage(_ item: SanityMedia) -> some View {
        VStack(alignment: .center, spacing: 8) {
            RemoteSanityImage(assetRef: item.asset._ref)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)

            if let caption = item.caption {
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(Theme.Colors.secondaryText)
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(item.alt ?? item.caption ?? "Image")
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        CosmoDetailView(
            pair: CosmoConsortPair(primary: .emanation(.sample()), consort: nil),
            returnLabel: "Aeons",
            onBack: {}
        )
    }
}
#endif