//
//  FrequencyPlayerView.swift
//  Divine Codex iOS
//
//  Full-screen Sacred Frequencies player — cover art, practice guidance, loop,
//  and favorites. The core personalization surface for App Store differentiation.
//

import SwiftUI

struct FrequencyPlayerView: View {

    let frequency: Frequency
    let frequenciesVM: SacredFrequenciesViewModel
    @Environment(\.dismiss) private var dismiss

    private var hasAudio: Bool {
        frequency.audioURL.flatMap(URL.init(string:)) != nil
    }

    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    coverArt
                    titleBlock
                    transportControls

                    if !hasAudio {
                        audioPendingBanner
                    }

                    if let guide = frequency.pronunciationGuide, !guide.isEmpty {
                        guidanceSection(title: "Pronunciation", body: guide)
                    }

                    if let notes = frequency.practiceNotes, !notes.isEmpty {
                        guidanceSection(title: "Practice", body: notes)
                    } else if let short = frequency.shortDescription {
                        guidanceSection(title: "About", body: short)
                    }

                    Spacer(minLength: 32)
                }
                .padding(24)
                .padding(.top, 8)
            }
        }
        .overlay(alignment: .topTrailing) {
            HStack(spacing: 12) {
                favoriteButton
                closeButton
            }
            .padding(16)
        }
        .onDisappear {
            if frequenciesVM.nowPlaying?.id == frequency.id, !frequenciesVM.isPlaying {
                frequenciesVM.stop()
            }
        }
    }

    // MARK: - Cover

    @ViewBuilder
    private var coverArt: some View {
        Group {
            if let asset = frequency.coverImage?.asset._ref {
                RemoteSanityImage(assetRef: asset)
                    .aspectRatio(1, contentMode: .fill)
            } else {
                ZStack {
                    RadialGradient(
                        colors: [
                            Theme.Colors.divineGold.opacity(0.25),
                            Theme.Colors.accent.opacity(0.15),
                            Theme.Colors.background
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 200
                    )
                    Image(systemName: "waveform.circle")
                        .font(.system(size: 72, weight: .light))
                        .foregroundStyle(Theme.Colors.divineGold.opacity(0.8))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 280)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.large))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.Radius.large)
                .stroke(Theme.Colors.primaryText.opacity(0.1), lineWidth: 1)
        }
    }

    private var titleBlock: some View {
        VStack(spacing: 8) {
            Text(frequency.displayTitle)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.Colors.primaryText)
                .multilineTextAlignment(.center)

            if frequenciesVM.nowPlaying?.id == frequency.id, frequenciesVM.isPlaying {
                Text("Playing")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.Colors.divineGold)
                    .textCase(.uppercase)
                    .tracking(1.2)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Transport

    private var transportControls: some View {
        HStack(spacing: 32) {
            Button {
                frequenciesVM.loopPlayback.toggle()
            } label: {
                Image(systemName: frequenciesVM.loopPlayback ? "repeat.circle.fill" : "repeat.circle")
                    .font(.system(size: 28))
                    .foregroundStyle(
                        frequenciesVM.loopPlayback
                            ? Theme.Colors.divineGold
                            : Theme.Colors.tertiaryText
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel(frequenciesVM.loopPlayback ? "Loop on" : "Loop off")

            Button {
                if hasAudio {
                    frequenciesVM.play(frequency)
                }
            } label: {
                Image(systemName: playButtonSymbol)
                    .font(.system(size: 52))
                    .foregroundStyle(hasAudio ? Theme.Colors.primaryText : Theme.Colors.tertiaryText)
            }
            .buttonStyle(.plain)
            .disabled(!hasAudio)
            .accessibilityLabel(hasAudio ? "Play or pause" : "Audio not yet available")
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private var playButtonSymbol: String {
        guard frequenciesVM.nowPlaying?.id == frequency.id, frequenciesVM.isPlaying else {
            return "play.circle.fill"
        }
        return "pause.circle.fill"
    }

    private var audioPendingBanner: some View {
        Text("Audio will appear here once hosted in Sanity. Text practice is ready now.")
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundStyle(Theme.Colors.secondaryText)
            .multilineTextAlignment(.center)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Theme.Radius.small))
    }

    private func guidanceSection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.Colors.divineGold)
                .textCase(.uppercase)
                .tracking(1.0)

            Text(body)
                .font(.system(size: 16))
                .foregroundStyle(Theme.Colors.primaryText.opacity(0.9))
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Chrome

    private var favoriteButton: some View {
        Button {
            frequenciesVM.toggleFavorite(frequency)
        } label: {
            Image(systemName: frequenciesVM.isFavorite(frequency) ? "heart.fill" : "heart")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(
                    frequenciesVM.isFavorite(frequency)
                        ? Theme.Colors.divineGold
                        : Theme.Colors.primaryText.opacity(0.85)
                )
                .padding(11)
                .background(.ultraThinMaterial, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(frequenciesVM.isFavorite(frequency) ? "Remove favorite" : "Add favorite")
    }

    private var closeButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "xmark")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.Colors.primaryText.opacity(0.85))
                .padding(11)
                .background(.ultraThinMaterial, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Close player")
    }
}

#if DEBUG
#Preview {
    FrequencyPlayerView(
        frequency: .sampleSet[0],
        frequenciesVM: SacredFrequenciesViewModel()
    )
}
#endif