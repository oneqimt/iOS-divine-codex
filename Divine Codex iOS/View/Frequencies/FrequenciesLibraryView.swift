//
//  FrequenciesLibraryView.swift
//  Divine Codex iOS
//
//  Browse and play Sacred Frequencies from Sanity. Supports favorites filtering.
//

import SwiftUI

struct FrequenciesLibraryView: View {

    @Environment(SanityViewModel.self) private var sanity
    @Environment(SacredFrequenciesViewModel.self) private var frequenciesVM
    @Environment(\.dismiss) private var dismiss

    @State private var showFavoritesOnly = false
    @State private var selectedFrequency: Frequency?

    private var allFrequencies: [Frequency] {
        sanity.frequencies
    }

    private var displayedFrequencies: [Frequency] {
        if showFavoritesOnly {
            return frequenciesVM.favorites(from: allFrequencies)
        }
        return allFrequencies
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()

                if allFrequencies.isEmpty {
                    emptyState
                } else {
                    frequencyList
                }
            }
            .navigationTitle("Sacred Frequencies")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Theme.Colors.secondaryText)
                }
                if !allFrequencies.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showFavoritesOnly.toggle()
                        } label: {
                            Image(systemName: showFavoritesOnly ? "heart.fill" : "heart")
                                .foregroundStyle(
                                    showFavoritesOnly
                                        ? Theme.Colors.divineGold
                                        : Theme.Colors.secondaryText
                                )
                        }
                        .accessibilityLabel(showFavoritesOnly ? "Show all" : "Show favorites")
                    }
                }
            }
            .sheet(item: $selectedFrequency) { frequency in
                FrequencyPlayerView(frequency: frequency, frequenciesVM: frequenciesVM)
            }
        }
    }

    private var frequencyList: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                if showFavoritesOnly && displayedFrequencies.isEmpty {
                    Text("No favorites yet — tap the heart on a frequency you cherish.")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundStyle(Theme.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 40)
                        .padding(.horizontal)
                }

                ForEach(displayedFrequencies) { frequency in
                    FrequencyRow(
                        frequency: frequency,
                        isFavorite: frequenciesVM.isFavorite(frequency),
                        isPlaying: frequenciesVM.nowPlaying?.id == frequency.id && frequenciesVM.isPlaying,
                        onPlay: { selectedFrequency = frequency },
                        onToggleFavorite: { frequenciesVM.toggleFavorite(frequency) }
                    )
                }
            }
            .padding(20)
        }
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
    }
}

// MARK: - Row

private struct FrequencyRow: View {

    let frequency: Frequency
    let isFavorite: Bool
    let isPlaying: Bool
    let onPlay: () -> Void
    let onToggleFavorite: () -> Void

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
            .background {
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .fill(Color.black.opacity(0.35))
                    .glassEffect(.clear, in: .rect(cornerRadius: Theme.Radius.medium))
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var rowThumbnail: some View {
        Group {
            if let asset = frequency.coverImage?.asset._ref {
                RemoteSanityImage(assetRef: asset)
                    .aspectRatio(1, contentMode: .fill)
            } else {
                Image(systemName: "waveform")
                    .font(.system(size: 22))
                    .foregroundStyle(Theme.Colors.divineGold.opacity(0.8))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Theme.Colors.accent.opacity(0.2))
            }
        }
        .frame(width: 56, height: 56)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#if DEBUG
#Preview {
    FrequenciesLibraryView()
        .environment(SanityViewModel.preview)
        .environment(SacredFrequenciesViewModel())
}
#endif