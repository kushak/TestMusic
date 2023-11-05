//
//  RecordControlsViewController.swift
//  MusicTest
//
//  Created by Oleg Shipulin on 02.11.2023.
//

import UIKit
import AVFoundation

protocol RecordControlsViewControllerOutput: AnyObject {
    func didRecordMic(url: URL)
    func didTapPlay()
    func didTapStop()
}

final class RecordControlsViewController: UIViewController {
    weak var output: RecordControlsViewControllerOutput?

    private let micRecorder = MicRecorder()
    private let audioOutputRecoder: AudioOutputRecoder

    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 20
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.setImage(UIImage(systemName: "stop.fill"), for: .selected)
        button.tintColor = .darkText
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(playAction), for: .touchUpInside)

        return button
    }()

    private lazy var recordButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 20
        button.setImage(UIImage(systemName: "record.circle"), for: .normal)
        button.tintColor = .darkText
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(recordAction), for: .touchUpInside)

        return button
    }()

    private lazy var micButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 20
        button.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        button.tintColor = .darkText
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(micAction), for: .touchUpInside)

        return button
    }()

    init(engine: AVAudioEngine) {
        audioOutputRecoder = AudioOutputRecoder(engine: engine)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {

        let views: [UIView] = [
            playButton,
            recordButton,
            micButton,
        ]

        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate(
            [
                playButton.rightAnchor.constraint(equalTo: view.rightAnchor),
                playButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                playButton.topAnchor.constraint(equalTo: view.topAnchor),
                playButton.widthAnchor.constraint(equalToConstant: 40),
                playButton.heightAnchor.constraint(equalToConstant: 40),

                recordButton.rightAnchor.constraint(equalTo: playButton.leftAnchor, constant: -8),
                recordButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                recordButton.widthAnchor.constraint(equalToConstant: 40),
                recordButton.heightAnchor.constraint(equalToConstant: 40),

                micButton.rightAnchor.constraint(equalTo: recordButton.leftAnchor, constant: -8),
                micButton.leftAnchor.constraint(equalTo: view.leftAnchor),
                micButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                micButton.widthAnchor.constraint(equalToConstant: 40),
                micButton.heightAnchor.constraint(equalToConstant: 40),
            ]
        )
    }

    @objc private func playAction() {
        if playButton.isSelected {
            playButton.tintColor = .darkText
            output?.didTapStop()
        } else {
            playButton.tintColor = .systemRed
            output?.didTapPlay()
        }
        playButton.isSelected.toggle()
    }

    @objc private func recordAction() {
        if recordButton.isSelected {
            recordButton.tintColor = .darkText
            guard let url = audioOutputRecoder.stop() else { return }
            share(url: url)
        } else {
            recordButton.tintColor = .systemRed
            audioOutputRecoder.record()
        }
        recordButton.isSelected.toggle()
    }

    @objc private func micAction() {
        if micButton.isSelected {
            micButton.tintColor = .darkText
            micRecorder.stopRecord { [weak self] url in
                guard let self else { return }
                output?.didRecordMic(url: url)
            }
        } else {
            micButton.tintColor = .systemRed
            micRecorder.startRecord()
        }
        micButton.isSelected.toggle()
    }

    private func share(url: URL) {
        let objectsToShare = [url]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
}
