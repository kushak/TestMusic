//
//  RecordControlsViewController.swift
//  MusicTest
//
//  Created by Oleg Shipulin on 02.11.2023.
//

import UIKit
import AVFoundation

protocol RecordControlsOutput: AnyObject {
    func didRecordMic(url: URL)
    func didTapPlay()
    func didTapStop()
}

protocol RecordControlsInput: UIViewController {
    var output: RecordControlsOutput? { get set }
}

final class RecordControlsViewController: UIViewController, RecordControlsInput {
    weak var output: RecordControlsOutput?

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


    private lazy var recordButtonLoader: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.color = UIColor(red: 128/255.0, green: 0/255.0, blue: 128/255.0, alpha: 1.0)
        view.hidesWhenStopped = true
        return view
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

    private lazy var micButtonLoader: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.color = UIColor(red: 128/255.0, green: 0/255.0, blue: 128/255.0, alpha: 1.0)
        view.hidesWhenStopped = true
        return view
    }()

    private lazy var micButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 20
        button.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        button.setImage(nil, for: .disabled)
        button.tintColor = .darkText
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(micAction), for: .touchUpInside)

        return button
    }()

    init(engine: AudioEngine) {
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
            micButtonLoader,
            recordButtonLoader,
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

                recordButtonLoader.centerXAnchor.constraint(equalTo: recordButton.centerXAnchor),
                recordButtonLoader.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor),

                micButton.rightAnchor.constraint(equalTo: recordButton.leftAnchor, constant: -8),
                micButton.leftAnchor.constraint(equalTo: view.leftAnchor),
                micButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                micButton.widthAnchor.constraint(equalToConstant: 40),
                micButton.heightAnchor.constraint(equalToConstant: 40),

                micButtonLoader.centerXAnchor.constraint(equalTo: micButton.centerXAnchor),
                micButtonLoader.centerYAnchor.constraint(equalTo: micButton.centerYAnchor),
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
            recordButton.isEnabled = false
            recordButton.tintColor = .white
            self.recordButtonLoader.startAnimating()
            DispatchQueue.main.async {
                guard let url = self.audioOutputRecoder.stop() else { return }
                self.share(url: url)
            }
        } else {
            recordButton.tintColor = .systemRed
            audioOutputRecoder.record()
        }
        recordButton.isSelected.toggle()
    }

    @objc private func micAction() {
        if micButton.isSelected {
            micButton.isSelected = false
            micButton.tintColor = .darkText
            micRecorder.stopRecord { [weak self] url in
                guard let self else { return }
                output?.didRecordMic(url: url)
            }
        } else {
            micButton.isEnabled = false
            self.micButtonLoader.startAnimating()
            self.micButton.tintColor = .white

            DispatchQueue.global(qos: .userInitiated).async {
                self.micRecorder.startRecord()
                DispatchQueue.main.async {
                    self.micButton.isEnabled = true
                    self.micButton.isSelected = true
                    self.micButtonLoader.stopAnimating()
                    self.micButton.tintColor = .systemRed
                }
            }
        }
    }

    private func share(url: URL) {
        let vc = FinalVisulizerViewController(url: url)
        navigationController?.pushViewController(vc, animated: true)
        //        let objectsToShare = [url]
        //        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        //        present(activityVC, animated: true) {
        self.recordButton.isEnabled = true
        self.recordButton.isSelected = false
        self.recordButton.tintColor = .darkText
        self.recordButtonLoader.stopAnimating()
        if playButton.isSelected {
            playAction()
        }
        //
        //        }
    }
}
