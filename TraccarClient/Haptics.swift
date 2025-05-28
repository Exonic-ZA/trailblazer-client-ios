//
//  Haptics.swift
//  TraccarClient
//
//  Created by Jordan Levy on 28/05/2025.
//  Copyright © 2025 Traccar. All rights reserved.
//

import UIKit

final class Haptics {
    private var progressiveTimer: Timer?
    private var pulseTimer: Timer?
    private var intensity: CGFloat = 0.2
    static let shared = Haptics()

    private init() {}

    func generateUrgentPulse() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()

        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                generator.impactOccurred()
            }
        }
    }

    func generateSoftTap() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    func generateWarning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }

    func generateSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    func generateError() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
    
    func startProgressivePulse() {
        stopProgressivePulse()
        pulseTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.impactOccurred()
        }
    }

    func stopProgressivePulse() {
        pulseTimer?.invalidate()
        pulseTimer = nil
    }
}
