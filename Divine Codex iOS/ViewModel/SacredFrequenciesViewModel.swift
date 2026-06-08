//
//  SacredFrequenciesViewModel.swift
//  Divine Codex iOS
//
//  Playback and favorites for Sacred Frequencies. Favorites persist in
//  UserDefaults for now; CloudKit sync is the planned next step for
//  cross-device personalization (mirroring Sacred Sites).
//

import AVFoundation
import Foundation
import Observation

@Observable
@MainActor
final class SacredFrequenciesViewModel {

    // MARK: - Playback state

    private(set) var nowPlaying: Frequency?
    private(set) var isPlaying = false
    var loopPlayback = true

    // MARK: - Favorites

    private(set) var favoriteIds: Set<String> = []

    private var player: AVPlayer?
    private var endObserver: Any?

    private static let favoritesKey = "sacredFrequencyFavorites"

    init() {
        loadFavorites()
        configureAudioSession()
    }

    // MARK: - Favorites

    func isFavorite(_ frequency: Frequency) -> Bool {
        favoriteIds.contains(frequency.id)
    }

    func toggleFavorite(_ frequency: Frequency) {
        if favoriteIds.contains(frequency.id) {
            favoriteIds.remove(frequency.id)
        } else {
            favoriteIds.insert(frequency.id)
        }
        saveFavorites()
    }

    func favorites(from all: [Frequency]) -> [Frequency] {
        all.filter { favoriteIds.contains($0.id) }
    }

    private func loadFavorites() {
        let stored = UserDefaults.standard.stringArray(forKey: Self.favoritesKey) ?? []
        favoriteIds = Set(stored)
    }

    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoriteIds), forKey: Self.favoritesKey)
    }

    // MARK: - Playback

    /// Seeds the loop toggle from Sanity when a frequency's player opens.
    /// User toggles after this are not overwritten by `play()`.
    func applyLoopDefault(from frequency: Frequency) {
        loopPlayback = frequency.audioLoopable ?? true
    }

    func play(_ frequency: Frequency) {
        guard let urlString = frequency.audioURL,
              let url = URL(string: urlString) else {
            nowPlaying = frequency
            isPlaying = false
            return
        }

        if nowPlaying?.id == frequency.id {
            togglePlayback()
            return
        }

        tearDownPlayer()
        nowPlaying = frequency

        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)
        observePlaybackEnd(for: item)
        player?.play()
        isPlaying = true
    }

    func togglePlayback() {
        guard let player, nowPlaying != nil else { return }
        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            resumePlayback(from: player)
        }
    }

    func stop() {
        tearDownPlayer()
        nowPlaying = nil
        isPlaying = false
    }

    private func tearDownPlayer() {
        player?.pause()
        player = nil
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
            self.endObserver = nil
        }
    }

    private func observePlaybackEnd(for item: AVPlayerItem) {
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                if self.loopPlayback {
                    self.player?.seek(to: .zero)
                    self.player?.play()
                } else {
                    self.isPlaying = false
                    // Rewind so the next play tap starts from the beginning.
                    self.player?.seek(to: .zero)
                }
            }
        }
    }

    private func resumePlayback(from player: AVPlayer) {
        guard let item = player.currentItem else {
            player.play()
            isPlaying = true
            return
        }

        let duration = item.duration
        let current = item.currentTime()
        let atEnd = duration.isNumeric && current.isNumeric
            && current.seconds >= max(0, duration.seconds - 0.1)

        if atEnd {
            player.seek(to: .zero) { [weak self] finished in
                guard let self, finished else { return }
                Task { @MainActor in
                    player.play()
                    self.isPlaying = true
                }
            }
        } else {
            player.play()
            isPlaying = true
        }
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default)
        try? session.setActive(true)
    }
}