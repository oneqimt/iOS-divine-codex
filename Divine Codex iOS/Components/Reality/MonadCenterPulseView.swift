//
//  MonadCenterPulseView.swift
//  Divine Codex iOS
//
//  SwiftUI center pulse (violet ↔ green) drawn above video or 2D orb backgrounds.
//

import SwiftUI

struct MonadCenterPulseView: View {

    var diameter: CGFloat

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let seconds = timeline.date.timeIntervalSinceReferenceDate
            let blend = 0.5 + 0.5 * sin(seconds * 2.2)
            let scale = 1.0 + 0.15 * sin(seconds * 2.2)

            Circle()
                .fill(pulseColor(blend: blend))
                .frame(width: diameter, height: diameter)
                .scaleEffect(scale)
                .shadow(color: pulseColor(blend: blend).opacity(0.85), radius: diameter * 0.35)
        }
    }

    private func pulseColor(blend: Double) -> Color {
        Color(
            red: 0.48 * (1 - blend) + 0.22 * blend,
            green: 0.32 * (1 - blend) + 0.82 * blend,
            blue: 0.95 * (1 - blend) + 0.52 * blend
        )
    }
}