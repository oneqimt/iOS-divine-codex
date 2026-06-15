//
//  MonadCenterPulseView.swift
//  Divine Codex iOS
//
//  SwiftUI center pulse (violet ↔ green) drawn above video or matte orb backgrounds.
//

import Combine
import SwiftUI

struct MonadCenterPulseView: View {

    var diameter: CGFloat
    /// False while detail covers the stage; timer restarts when this becomes true again.
    var isAnimating: Bool = true

    @State private var phase: Double = 0
    @State private var timerCancellable: AnyCancellable?

    /// One full violet ↔ green cycle ≈ 4.8s at 30fps.
    private let pulseFrequency = 1.3

    var body: some View {
        Circle()
            .fill(pulseColor(blend: 0.5 + 0.38 * sin(phase * pulseFrequency)))
            .frame(width: diameter, height: diameter)
            .scaleEffect(1.0 + 0.06 * sin(phase * pulseFrequency))
            .onAppear { restartTimer() }
            .onDisappear { stopTimer() }
            .onChange(of: isAnimating) { _, animating in
                if animating {
                    restartTimer()
                } else {
                    stopTimer()
                }
            }
    }

    private func restartTimer() {
        stopTimer()
        phase = 0
        guard isAnimating else { return }

        timerCancellable = Timer.publish(every: 1.0 / 30.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                phase += 1.0 / 30.0
            }
    }

    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    private func pulseColor(blend: Double) -> Color {
        Color(
            red: 0.48 * (1 - blend) + 0.12 * blend,
            green: 0.32 * (1 - blend) + 0.40 * blend,
            blue: 0.95 * (1 - blend) + 0.34 * blend
        )
    }
}
