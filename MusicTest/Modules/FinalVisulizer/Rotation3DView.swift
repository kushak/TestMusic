//
//  Rotation3DView.swift
//  MusicTest
//
//  Created by Oleg Shipulin on 02.12.2023.
//

import UIKit


final class Rotation3DView: UIImageView {

    override var image: UIImage? {
        get { super.image }
        set {
            super.image = newValue
//            animate()
        }
    }

    func animate() {
        UIView.animate(
            withDuration: 10,
            delay: 3,
            options: .curveEaseOut,
            animations: { [weak self] in
                guard let self else { return }
                let trans = CABasicAnimation(keyPath: "transform");
                trans.fromValue = [0.0, 0.0, 1.0, 0.0] // you may have to correct this
                trans.toValue = [10 * .pi / 180.0, 0.0, 1.0, 0.0]   // That's my guess of the correct set of parameters
                layer.add(trans, forKey: "rotation")
            },
            completion: { done in
                print("+++ animation done \(done)")
            }
        )
    }

    func randomRotatingAnimation() {
        layer.removeAnimation(forKey: "MyRotation")
        let randomDuration = Double.random(in: 0..<0.8) + 0.2

        let currentAngle = (layer.presentation()?.value(forKeyPath: "transform.rotation") as? NSNumber)?.floatValue ?? 0.0
        let randomAngle = Float.random(in: 0..<(2 * .pi))
        let newAngle = currentAngle + randomAngle

        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = NSNumber(value: newAngle)
        rotationAnimation.byValue = NSNumber(value: randomAngle)
        rotationAnimation.toValue = NSNumber(value: newAngle + randomAngle)
        rotationAnimation.duration = randomDuration
        rotationAnimation.repeatCount = .infinity
        rotationAnimation.isRemovedOnCompletion = false

        layer.add(rotationAnimation, forKey: "MyRotation")
    }

}

protocol AnimatableView: UIView {
    func animate()
}
