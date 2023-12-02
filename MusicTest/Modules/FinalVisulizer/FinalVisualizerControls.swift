//
//  FinalVisualizerControls.swift
//  MusicTest
//
//  Created by Oleg Shipulin on 02.12.2023.
//

import UIKit


typealias Action = () -> Void

final class FinalVisualizerControls: UIView {

    enum Constants {
        static let buttonSize: CGFloat = 50
    }

    var playAction: Action?
    var pauseAction: Action?
    var forwardAction: Action?
    var backwardAction: Action?

    private let leftTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white

        return label
    }()
    private let rightTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .right

        return label
    }()

    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = Constants.buttonSize / 2
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)

        button.setImage(UIImage(systemName: "pause.fill"), for: .selected)
        button.tintColor = .darkText
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(didTapPlay), for: .touchUpInside)

        return button
    }()


    private lazy var forwardButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = Constants.buttonSize / 2
        button.setImage(UIImage(systemName: "forward.fill"), for: .normal)
        button.tintColor = .darkText
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(didTapForward), for: .touchUpInside)

        return button
    }()

    private lazy var backwardButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = Constants.buttonSize / 2
        button.setImage(UIImage(systemName: "backward.fill"), for: .normal)
        button.tintColor = .darkText
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(didTapBackward), for: .touchUpInside)

        return button
    }()

    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func stop() {
        playButton.isSelected = false
    }

    func setLeft(time: TimeInterval) {
        leftTimeLabel.text = stringFromTimeInterval(interval: time)
    }

    func setRight(time: TimeInterval) {
        rightTimeLabel.text = stringFromTimeInterval(interval: time)
    }


    private func setupView() {
        let views: [UIView] = [
            leftTimeLabel,
            rightTimeLabel,
            playButton,
            forwardButton,
            backwardButton,
        ]

        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate(
            [
                leftTimeLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
                leftTimeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

                rightTimeLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
                rightTimeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

                playButton.centerXAnchor.constraint(equalTo: centerXAnchor),
                playButton.centerYAnchor.constraint(equalTo: centerYAnchor),
                playButton.bottomAnchor.constraint(equalTo: bottomAnchor),
                playButton.topAnchor.constraint(equalTo: topAnchor),
                playButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
                playButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),

                forwardButton.leftAnchor.constraint(equalTo: playButton.rightAnchor, constant: 10),
                forwardButton.centerYAnchor.constraint(equalTo: centerYAnchor),
                forwardButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
                forwardButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),

                backwardButton.rightAnchor.constraint(equalTo: playButton.leftAnchor, constant: -10),
                backwardButton.centerYAnchor.constraint(equalTo: centerYAnchor),
                backwardButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
                backwardButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
            ]
        )
    }

    @objc private func didTapPlay() {
        if playButton.isSelected {
            pauseAction?()
        } else {
            playAction?()
        }
        playButton.isSelected.toggle()
    }

    @objc private func didTapForward() {
        forwardAction?()
    }

    @objc private func didTapBackward() {
        backwardAction?()
    }

    private func stringFromTimeInterval(interval: TimeInterval) -> String {
        let ti = NSInteger(interval)
        let ms = Int((interval) * 1000)
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        return NSString(format: "%0.2d:%0.2d", minutes, seconds) as String
    }
}
