//
//  SampleSettingsViewController.swift
//  MusicTest
//
//  Created by Oleg Shipulin on 01.11.2023.
//

import UIKit

struct SampleSettings {
    let volume: Float
    let rate: Float

    var delay: Float {
        let k = (rate - 0.5) / 1.5
        let delay = 5 - k * 5
        return delay
    }
}

protocol SampleSettingsOutput: AnyObject {

    func didChange(settings: SampleSettings)

}

final class SampleSettingsViewController: UIViewController {
    weak var output: SampleSettingsOutput?

    private let volumeSlider = UISlider()
    private let rateSlider = UISlider()

    var currentSettings: SampleSettings {
        .init(volume: volumeSlider.value, rate: rateSlider.value)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let sliderContainerView = UIView()
        let views: [UIView] = [
            sliderContainerView,
            rateSlider,
        ]

        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        volumeSlider.translatesAutoresizingMaskIntoConstraints = false
        sliderContainerView.addSubview(volumeSlider)

        volumeSlider.minimumValueImage = UIImage(systemName: "speaker.wave.1.fill")
        volumeSlider.maximumValueImage = UIImage(systemName: "speaker.wave.3.fill")
        volumeSlider.tintColor = .white
        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 1
        volumeSlider.value = 1
        volumeSlider.transform = CGAffineTransform(rotationAngle: -.pi / 2)
        volumeSlider.addTarget(self, action: #selector(didUpdateSettings), for: .valueChanged)

        rateSlider.minimumValueImage = UIImage(systemName: "play.fill")?.withRenderingMode(.alwaysTemplate)
        rateSlider.maximumValueImage = UIImage(systemName: "forward.fill")?.withRenderingMode(.alwaysTemplate)
        rateSlider.tintColor = .white
        rateSlider.minimumValue = 0.5
        rateSlider.maximumValue = 2
        rateSlider.value = 1.5
        rateSlider.addTarget(self, action: #selector(didUpdateSettings), for: .valueChanged)

        NSLayoutConstraint.activate(
            [
                volumeSlider.centerXAnchor.constraint(equalTo: sliderContainerView.centerXAnchor),
                volumeSlider.centerYAnchor.constraint(equalTo: sliderContainerView.centerYAnchor),
                volumeSlider.widthAnchor.constraint(equalTo: sliderContainerView.heightAnchor),
                volumeSlider.heightAnchor.constraint(equalTo: sliderContainerView.widthAnchor),

                sliderContainerView.leftAnchor.constraint(equalTo: view.leftAnchor),
                sliderContainerView.topAnchor.constraint(equalTo: view.topAnchor),
                sliderContainerView.widthAnchor.constraint(equalToConstant: 50),
                sliderContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),

                rateSlider.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50),
                rateSlider.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50),
                rateSlider.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                rateSlider.heightAnchor.constraint(equalToConstant: 50),
            ]
        )
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateSettings(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateSettings(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateSettings(touches, with: event)
    }

    func configure(with settings: SampleSettings) {
        volumeSlider.value = settings.volume
        rateSlider.value = settings.rate
    }

    private func updateSettings(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let volume = calculateVolume(for: touch)
        let rate = calculateRate(for: touch)
        volumeSlider.value = volume
        rateSlider.value = rate

        didUpdateSettings()
    }

    @objc
    private func didUpdateSettings() {
        output?.didChange(
            settings: .init(
                volume: volumeSlider.value,
                rate: rateSlider.value
            )
        )
    }

    private func calculateVolume(for touch: UITouch) -> Float {
        var point = touch.location(in: view)
        let lineInset: CGFloat = 38
        let lineHeight = volumeSlider.frame.height - 2 * lineInset
        point.y = max(point.y - lineInset, 0)
        point.y = min(point.y, lineHeight)
        let volume = Float((lineHeight - point.y) / lineHeight)

        return volume
    }

    private func calculateRate(for touch: UITouch) -> Float {
        var point = touch.location(in: rateSlider)
        let lineInset: CGFloat = 38
        let lineWidth = rateSlider.frame.width - 2 * lineInset
        point.x = max(point.x - lineInset, 0)
        point.x = min(point.x, lineWidth)
        var rate = Float(point.x / lineWidth)
        rate = 0.5 + 1.5 * rate

        return rate
    }
}
