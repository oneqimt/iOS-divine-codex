//
//  LoopingMutedVideoView.swift
//  Divine Codex iOS
//
//  Muted, looping MP4/HLS cover clip for ambient hero visuals in the
//  Sacred Frequencies player. Audio practice uses a separate AVPlayer.
//

import AVFoundation
import AVKit
import SwiftUI

struct LoopingMutedVideoView: UIViewControllerRepresentable {

    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        controller.view.backgroundColor = .clear

        let template = AVPlayerItem(url: url)
        let queue = AVQueuePlayer()
        queue.isMuted = true
        context.coordinator.looper = AVPlayerLooper(player: queue, templateItem: template)
        controller.player = queue
        queue.play()

        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player?.play()
    }

    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: Coordinator) {
        uiViewController.player?.pause()
        coordinator.looper?.disableLooping()
        coordinator.looper = nil
        uiViewController.player = nil
    }

    final class Coordinator {
        var looper: AVPlayerLooper?
    }
}