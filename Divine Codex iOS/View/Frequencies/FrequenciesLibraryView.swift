//
//  FrequenciesLibraryView.swift
//  Divine Codex iOS
//
//  Browse and play Sacred Frequencies from Sanity. Favorites via each row's heart.
//

import SwiftUI

struct FrequenciesLibraryView: View {

    @Environment(SanityViewModel.self) private var sanity
    @Environment(FrequenciesViewModel.self) private var frequenciesVM
    @Environment(\.dismiss) private var dismiss

    @State private var selectedFrequency: Frequency?

    /// Extra space between the status bar (time/date) and the library header.
    private let statusBarBreathingRoom: CGFloat = 18

    private var allFrequencies: [Frequency] {
        sanity.frequencies
    }

    var body: some View {
        VStack(spacing: 0) {
            libraryHeader

            ZStack {
                Theme.Colors.background

                if allFrequencies.isEmpty {
                    emptyState
                } else {
                    frequencyList
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Theme.Colors.background)
        .fullScreenCover(item: $selectedFrequency) { frequency in
            FrequencyPlayerView(frequency: frequency, frequenciesVM: frequenciesVM)
        }
    }

    private var libraryHeader: some View {
        HStack {
            Button("Close") { dismiss() }
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundStyle(Theme.Colors.secondaryText)

            Spacer()

            Text("Sacred Frequencies")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.Colors.primaryText)

            Spacer()

            // Balances the leading Close control so the title stays centered.
            Color.clear
                .frame(width: 52, height: 1)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 20)
        .padding(.top, statusBarBreathingRoom)
        .padding(.bottom, 12)
    }

    private var frequencyList: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(allFrequencies) { frequency in
                    FrequencyRow(
                        frequency: frequency,
                        isFavorite: frequenciesVM.isFavorite(frequency),
                        isPlaying: frequenciesVM.nowPlaying?.id == frequency.id && frequenciesVM.isPlaying,
                        onPlay: { selectedFrequency = frequency },
                        onToggleFavorite: { frequenciesVM.toggleFavorite(frequency) }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 15)
            .padding(.bottom, 20)
        }
        .scrollClipDisabled()
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "waveform")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(Theme.Colors.divineGold.opacity(0.7))

            Text("Frequencies are on their way")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.Colors.primaryText)

            Text("Add `frequency` documents in Sanity Studio with audio URLs and cover images. They will appear here automatically.")
                .font(.system(size: 15))
                .foregroundStyle(Theme.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if sanity.isLoading {
                ProgressView()
                    .tint(Theme.Colors.divineGold)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 15)
    }
}

// MARK: - Row

private struct FrequencyRow: View {

    let frequency: Frequency
    let isFavorite: Bool
    let isPlaying: Bool
    let onPlay: () -> Void
    let onToggleFavorite: () -> Void

    private var rowShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous)
    }

    var body: some View {
        Button(action: onPlay) {
            HStack(spacing: 16) {
                rowThumbnail

                VStack(alignment: .leading, spacing: 4) {
                    Text(frequency.displayTitle)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.Colors.primaryText)
                        .lineLimit(2)

                    if let short = frequency.shortDescription {
                        Text(short)
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.Colors.secondaryText)
                            .lineLimit(2)
                    }

                    if isPlaying {
                        Text("Now playing")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Theme.Colors.divineGold)
                    }
                }

                Spacer(minLength: 0)

                Button(action: onToggleFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(isFavorite ? Theme.Colors.divineGold : Theme.Colors.tertiaryText)
                        .padding(8)
                }
                .buttonStyle(.plain)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                rowShape.fill(Color.black.opacity(0.70))
            }
            .overlay {
                // strokeBorder draws inside the shape so corners are not clipped by the row bounds.
                rowShape.strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
            }
            .contentShape(rowShape)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var rowThumbnail: some View {
        Group {
            if let asset = frequency.coverImage?.asset._ref {
                RemoteSanityImage(assetRef: asset, contentMode: .fill)
            } else {
                Image(systemName: "waveform")
                    .font(.system(size: 28))
                    .foregroundStyle(Theme.Colors.divineGold.opacity(0.8))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Theme.Colors.accent.opacity(0.8))
            }
        }
        .frame(width: 80, height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .shadow(color: .black.opacity(0.8), radius: 3, x: 0, y: 2)
    }
}

#if DEBUG
#Preview {
    FrequenciesLibraryView()
        .environment(SanityViewModel.preview)
        .environment(FrequenciesViewModel())
}
#endif
