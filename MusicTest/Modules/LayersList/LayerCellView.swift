//
//  LayerCellView.swift
//  MusicTest
//
//  Created by Oleg Shipulin on 01.11.2023.
//

import UIKit

final class LayerCellView: UIView {

    struct Model {
        let title: String
        let didTapCell: () -> Void
        let didTapPlay: (Bool) -> Void
        let didTapMute: (Bool) -> Void
        let didTapDelete: () -> Void
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        return label
    }()

    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.setImage(UIImage(systemName: "pause.fill"), for: .selected)
        button.tintColor = .darkText
        button.addTarget(self, action: #selector(playAction), for: .touchUpInside)

        return button
    }()

    private lazy var muteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "speaker.fill"), for: .normal)
        button.setImage(UIImage(systemName: "speaker.slash.fill"), for: .selected)
        button.tintColor = .darkText
        button.addTarget(self, action: #selector(muteAction), for: .touchUpInside)

        return button
    }()

    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .darkText
        button.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)

        return button
    }()

    private var didTapCell: (() -> Void)?
    private var didTapPlay: ((Bool) -> Void)?
    private var didTapMute: ((Bool) -> Void)?
    private var didTapDelete: (() -> Void)?

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with model: Model) {
        titleLabel.text = model.title

        didTapCell = model.didTapCell
        didTapPlay = model.didTapPlay
        didTapMute = model.didTapMute
        didTapDelete = model.didTapDelete
    }

    func displayPlayState(_ play: Bool) {
        playButton.isSelected = play
    }

    private func setupView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        addGestureRecognizer(tap)
        layer.cornerRadius = 20
        backgroundColor = .white

        let views: [UIView] = [
            titleLabel,
            playButton,
            muteButton,
            deleteButton,
        ]

        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate(
            [
                heightAnchor.constraint(equalToConstant: 40),

                titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 12),
                titleLabel.topAnchor.constraint(equalTo: topAnchor),
                titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),

                playButton.rightAnchor.constraint(equalTo: muteButton.leftAnchor),
                playButton.topAnchor.constraint(equalTo: topAnchor),
                playButton.bottomAnchor.constraint(equalTo: bottomAnchor),
                playButton.widthAnchor.constraint(equalToConstant: 40),

                muteButton.rightAnchor.constraint(equalTo: deleteButton.leftAnchor),
                muteButton.topAnchor.constraint(equalTo: topAnchor),
                muteButton.bottomAnchor.constraint(equalTo: bottomAnchor),
                muteButton.widthAnchor.constraint(equalToConstant: 40),

                deleteButton.rightAnchor.constraint(equalTo: rightAnchor),
                deleteButton.topAnchor.constraint(equalTo: topAnchor),
                deleteButton.bottomAnchor.constraint(equalTo: bottomAnchor),
                deleteButton.widthAnchor.constraint(equalToConstant: 40),
            ]
        )
    }

    @objc private func tapAction() {
        didTapCell?()
    }

    @objc private func playAction() {
        playButton.isSelected.toggle()
        didTapPlay?(playButton.isSelected)
    }

    @objc private func muteAction() {
        muteButton.isSelected.toggle()
        didTapMute?(muteButton.isSelected)
    }

    @objc private func deleteAction() {
        didTapDelete?()
    }
}
