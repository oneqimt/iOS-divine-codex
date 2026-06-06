//
//  PortableTextView.swift
//  Divine Codex iOS
//
//  Renders an array of `PortableTextBlock`s (Sanity Portable Text) into
//  SwiftUI. Adapted from the established pattern used elsewhere: text blocks
//  render their child spans joined together; image blocks render the asset
//  with an optional caption.
//
//  IMAGES:
//  This project intentionally uses `AsyncImage` (see `RemoteSanityImage`),
//  which is sufficient for the modest number of images here — URLSession's
//  shared cache avoids re-downloading within a session. If the content ever
//  scales to many high-resolution images, swap in a dedicated cached image
//  view at the single marked swap point; nothing else needs to change.
//

import SwiftUI

struct PortableTextView: View {

    let blocks: [PortableTextBlock]

    /// Body font for text blocks. Defaults to `.callout`; pass `.body` for iPad.
    var textFont: Font = .callout

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(blocks, id: \._key) { block in
                if block._type == "image", block.asset != nil {
                    PortableTextImageBlock(block: block)
                        .padding(.vertical, 8)
                } else if let children = block.children, !children.isEmpty {
                    let text = children.map(\.text).joined()
                    if !text.isEmpty {
                        Text(text)
                            .font(textFont)
                            .foregroundStyle(Theme.Colors.primaryText.opacity(0.9))
                            .lineSpacing(6)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
}

// MARK: - Image Block

private struct PortableTextImageBlock: View {

    let block: PortableTextBlock

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            if let assetRef = block.asset?._ref {
                RemoteSanityImage(assetRef: assetRef)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(radius: 2)
            }

            if let caption = block.caption {
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(Theme.Colors.secondaryText)
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }
}

// MARK: - Remote Image (swap point for the cached implementation)

/// A single place that resolves a Sanity asset-ref into an image view.
///
/// Backed by `AsyncImage`, which is the chosen approach for this project's
/// modest image count. If image volume ever grows enough to justify a
/// dedicated cache, replace the body here with a cached image view, e.g.:
///
///     CachedImageView(assetRef: assetRef, contentMode: .fit)
///
/// …and remove the `AsyncImage` branch. This is the only place that needs to
/// change, so adopting caching later is a one-view edit.
///
/// Used by both `PortableTextView` (inline image blocks) and `CosmoSidebar`
/// (the media gallery), so it is intentionally non-private.
struct RemoteSanityImage: View {
    let assetRef: String

    var body: some View {
        if let url = SanityImageURL.url(forAssetRef: assetRef) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure:
                    placeholder(systemImage: "photo")
                case .empty:
                    placeholder(systemImage: "photo", showsProgress: true)
                @unknown default:
                    placeholder(systemImage: "photo")
                }
            }
        } else {
            placeholder(systemImage: "photo")
        }
    }

    private func placeholder(systemImage: String, showsProgress: Bool = false) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.06))
                .aspectRatio(16.0 / 9.0, contentMode: .fit)
            if showsProgress {
                ProgressView()
            } else {
                Image(systemName: systemImage)
                    .font(.system(size: 28))
                    .foregroundStyle(Theme.Colors.secondaryText)
            }
        }
    }
}

// MARK: - Sanity Asset Ref → URL

/// Builds a Sanity CDN image URL from an asset reference string like
/// `image-<assetId>-<width>x<height>-<format>`.
///
/// Uses the project's existing `sanityProjectId` / `sanityDataset` constants
/// (defined in SanityClient.swift) so there's a single source of truth.
enum SanityImageURL {

    static func url(forAssetRef ref: String) -> URL? {
        // Format: image-<id>-<dimensions>-<format>
        let parts = ref.split(separator: "-")
        guard parts.count == 4, parts[0] == "image" else { return nil }
        let id = parts[1]
        let dimensions = parts[2]
        let format = parts[3]
        let filename = "\(id)-\(dimensions).\(format)"
        return URL(string: "https://cdn.sanity.io/images/\(sanityProjectId)/\(sanityDataset)/\(filename)")
    }
}
