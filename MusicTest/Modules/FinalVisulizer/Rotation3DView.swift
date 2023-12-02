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

//    func animate() {
//        UIView.animate(
//            withDuration: 10,
//            delay: 3,
//            options: .curveEaseOut,
//            animations: { [weak self] in
//                guard let self else { return }
//                let trans = CABasicAnimation(keyPath: "transform");
//                trans.fromValue = [0.0, 0.0, 1.0, 0.0] // you may have to correct this
//                trans.toValue = [10 * .pi / 180.0, 0.0, 1.0, 0.0]   // That's my guess of the correct set of parameters
//                layer.add(trans, forKey: "rotation")
//            },
//            completion: { done in
//                print("+++ animation done \(done)")
//            }
//        )
//    }

    func randomRotatingAnimation() {
//        layer.removeAnimation(forKey: "MyRotation")
        let randomDuration = Double.random(in: 0..<0.8) + 0.2
//
//        let currentAngle = (layer.presentation()?.value(forKeyPath: "transform.rotation") as? NSNumber)?.floatValue ?? 0.0
        let randomAngle = CGFloat.random(in: 0..<(2 * .pi))
//        let newAngle = currentAngle + randomAngle
//
//        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
//        rotationAnimation.fromValue = NSNumber(value: newAngle)
//        rotationAnimation.byValue = NSNumber(value: randomAngle)
//        rotationAnimation.toValue = NSNumber(value: newAngle + randomAngle)
//        rotationAnimation.duration = randomDuration
//        rotationAnimation.repeatCount = .infinity
//        rotationAnimation.isRemovedOnCompletion = false
//
//        layer.add(rotationAnimation, forKey: "MyRotation")

//        UIView.animate(withDuration: randomDuration) { [weak self] in
//            self.layer.transform = CATransform3DConcat(
//                self.layer.transform,
//                CATransform3DMakeRotation(
//                    randomAngle,
//                    .random(in: 0...1),
//                    .random(in: 0...1),
//                    .random(in: 0...1)
//                )
//            )
//        }

        rotate()
//        scale()
        move()
    }

}


extension UIView {

    func scale() {
        let randomDuration = Double.random(in: 0..<0.8) + 0.2
        let randomAngle = CGFloat.random(in: 0..<(2 * .pi))

        let scale = CGFloat.random(in: 0.5...1.5)
        UIView.animate(withDuration: randomDuration) { [weak self] in
            guard let self else { return }
            layer.transform = CATransform3DConcat(
                layer.transform,
//                CATransform3DScale(
//                    randomAngle,
//                    .random(in: 0.5...1.5),
//                    .random(in: 0.5...1.5),
//                    .random(in: 0.5...1.5)
//                )
                CATransform3DScale(layer.transform ?? CATransform3DIdentity, scale, scale, scale)
            )
        }
    }

    func rotate() {
        let randomDuration = Double.random(in: 0..<0.8) + 0.2
        let randomAngle = CGFloat.random(in: 0..<(2 * .pi))

        UIView.animate(withDuration: randomDuration) { [weak self] in
            guard let self else { return }
            layer.transform = CATransform3DConcat(
                layer.transform,
                CATransform3DMakeRotation(
                    randomAngle,
                    .random(in: 0...1),
                    .random(in: 0...1),
                    .random(in: 0...1)
                )
            )
        }
    }

    func move() {
        guard let superview else { return }
        let randomDuration = Double.random(in: 3..<15)

        let randomX = CGFloat.random(
            in: 0...max(0, (superview.bounds.width - frame.width))
        )
        let randomY = CGFloat.random(
            in: 0...max(0, (superview.bounds.height - frame.height))
        )

        let randomOrigin = CGPoint(
            x: randomX,
            y: randomY
        )

        UIView.animate(withDuration: randomDuration) { [weak self] in
            guard let self else { return }
            frame.origin = randomOrigin
        }
    }
}

protocol AnimatableView: UIView {
    func animate()
}
