//
//  PulseAnimation.swift
//  TraccarClient
//
//  Created by Balleng Balleng on 2025/01/06.
//  Copyright © 2025 Traccar. All rights reserved.
//

//
//  PulseAnimation.swift
//  TraccarClient
//
//  Created by Balleng Balleng on 2025/01/06.
//  Copyright © 2025 Traccar. All rights reserved.
//

import UIKit

class PulseAnimation: CALayer {

    private var animationGroup = CAAnimationGroup()
    var animationDuration: TimeInterval = 1.5
    var radius: CGFloat = 200
    var numberOfPulses: Float = 10
    var shouldRepeatForever: Bool = false

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(
        numberOfPulses: Float = 10,
        radius: CGFloat,
        position: CGPoint,
        color: UIColor = .black,
        repeatForever: Bool = false
    ) {
        super.init()
        self.backgroundColor = color.cgColor
        self.contentsScale = UIScreen.main.scale
        self.opacity = 0
        self.radius = radius
        self.numberOfPulses = numberOfPulses
        self.position = position
        self.shouldRepeatForever = repeatForever
        self.name = "pulseLayer"

        self.bounds = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
        self.cornerRadius = radius

        DispatchQueue.global(qos: .default).async {
            self.setupAnimationGroup()
            DispatchQueue.main.async {
                self.add(self.animationGroup, forKey: "pulse")
            }
        }
    }

    private func scaleAnimation() -> CABasicAnimation {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
        scaleAnimation.fromValue = 0
        scaleAnimation.toValue = 1
        scaleAnimation.duration = animationDuration
        return scaleAnimation
    }

    private func createOpacityAnimation() -> CAKeyframeAnimation {
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.duration = animationDuration
        opacityAnimation.keyTimes = [0, 0.3, 1]
        opacityAnimation.values = [0.4, 0.8, 0]
        return opacityAnimation
    }

    private func setupAnimationGroup() {
        animationGroup.duration = animationDuration
        animationGroup.repeatCount = shouldRepeatForever ? .infinity : numberOfPulses
        animationGroup.timingFunction = CAMediaTimingFunction(name: .default)
        animationGroup.animations = [scaleAnimation(), createOpacityAnimation()]
    }
}
