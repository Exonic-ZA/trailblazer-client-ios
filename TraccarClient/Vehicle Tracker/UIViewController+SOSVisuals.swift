//
//  UIViewController+SOSVisuals.swift
//  TraccarClient
//
//  Created by Jordan Levy on 28/05/2025.
//  Copyright © 2025 Traccar. All rights reserved.
//

import UIKit

extension VehicleTrackerViewController {

    func sosVisualState(active: Bool) {
        if active {
            triggerPulseAnimation()
        } else {
            fadeOutPulseAnimation()
        }
    }

    func triggerPulseAnimation() {
        // Remove existing pulse layers
        self.view.layer.sublayers?
            .filter { $0.name == "pulseLayer" }
            .forEach { $0.removeFromSuperlayer() }

        // Create new pulses
        func createPulse(at position: CGPoint, color: UIColor) -> PulseAnimation {
            let pulse = PulseAnimation(
                numberOfPulses: 1,
                radius: 50,
                position: position,
                color: color,
                repeatForever: true
            )
            pulse.animationDuration = 1.0
            pulse.name = "pulseLayer"
            return pulse
        }

        let labelPulse = createPulse(at: connectedLabel.center, color: .green)
        self.view.layer.insertSublayer(labelPulse, below: self.view.layer)

        let sosPulse = createPulse(at: sosButton.center, color: .red)
        self.view.layer.insertSublayer(sosPulse, below: self.view.layer)

        Haptics.shared.generateUrgentPulse()

        // SOS button border + glow
        sosButton.layer.borderColor = UIColor.red.cgColor
        sosButton.layer.borderWidth = 2
        sosButton.layer.cornerRadius = sosButton.frame.size.height / 2
        sosButton.clipsToBounds = false
        sosButton.layer.shadowColor = UIColor.red.cgColor
        sosButton.layer.shadowRadius = 10
        sosButton.layer.shadowOpacity = 0.8
        sosButton.layer.shadowOffset = .zero

        // Glowing animation (not blinking border)
        let glowPulse = CABasicAnimation(keyPath: "shadowOpacity")
        glowPulse.fromValue = 0.8
        glowPulse.toValue = 0.2
        glowPulse.duration = 1.0
        glowPulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        glowPulse.autoreverses = true
        glowPulse.repeatCount = .infinity
        glowPulse.beginTime = CACurrentMediaTime()
        sosButton.layer.add(glowPulse, forKey: "sosGlowPulse")
    }

    func fadeOutPulseAnimation() {
        // Animate out the pulse layers
        self.view.layer.sublayers?
            .filter { $0.name == "pulseLayer" }
            .forEach {
                let fade = CABasicAnimation(keyPath: "opacity")
                fade.fromValue = $0.opacity
                fade.toValue = 0
                fade.duration = 0.3
                fade.fillMode = .forwards
                fade.isRemovedOnCompletion = false
                $0.add(fade, forKey: "fadeOut")
            }

        // Remove pulse layers after fade
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.view.layer.sublayers?
                .filter { $0.name == "pulseLayer" }
                .forEach { $0.removeFromSuperlayer() }
        }

        // Remove SOS button visual effects
        sosButton.layer.removeAnimation(forKey: "sosGlowPulse")
        sosButton.layer.borderWidth = 0
        sosButton.layer.shadowOpacity = 0
        sosButton.layer.shadowRadius = 0

        // Optional label flash cleanup
        sosMessage.layer.removeAnimation(forKey: "sosMessageFlash")
    }
}
