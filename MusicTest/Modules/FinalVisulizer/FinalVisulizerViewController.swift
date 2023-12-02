//
//  FinalVisulizerViewController.swift
//  MusicTest
//
//  Created by Oleg Shipulin on 02.12.2023.
//

import AVFoundation
import UIKit

final class FinalVisulizerViewController: UIViewController {

    private let url: URL
    private let audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private let controlsView = FinalVisualizerControls()
    private lazy var progressSlider: UISlider = {
        let slider = UISlider()
        slider.tintColor = .white
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0
        slider.addTarget(self, action: #selector(didChangeProgress), for: .valueChanged)

        return slider
    }()

    private var animatableView: [Rotation3DView] = []

    init(url: URL) {
        self.url = url
        audioPlayer = try! AVAudioPlayer(contentsOf: url)

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        audioPlayer?.delegate = self
        navigationItem.title =  String(url.lastPathComponent.components(separatedBy: ".").first!)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(didTapBack)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.down.to.line.square"),
            style: .plain,
            target: self,
            action: #selector(didTapShare)
        )
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationItem.rightBarButtonItem?.tintColor = .white

        let views: [UIView] = [
            progressSlider,
            controlsView,
        ]

        controlsView.layer.zPosition = 1000

        views.forEach {
            $0.layer.zPosition = 1000
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

//        animatableView.forEach {
//            $0.image = UIImage(named: "Rectangle")
////            $0.frame = .init(origin: .init(x: 10, y: 100), size: .init(width: 100, height: 100))
//
//            $0.layer.zPosition = 500
//            $0.layer.masksToBounds = false
//            view.addSubview($0)
//        }

        NSLayoutConstraint.activate(
            [
                controlsView.rightAnchor.constraint(equalTo: view.rightAnchor),
                controlsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                controlsView.leftAnchor.constraint(equalTo: view.leftAnchor),
                controlsView.heightAnchor.constraint(equalToConstant: FinalVisualizerControls.Constants.buttonSize),


                progressSlider.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
                progressSlider.bottomAnchor.constraint(equalTo: controlsView.topAnchor, constant: -10),
                progressSlider.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),

            ]
        )

        controlsView.playAction = { [weak self] in
            guard let self else { return }
            audioPlayer?.play()
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
                guard let self, let player = audioPlayer else { return }

                progressSlider.value = Float(player.currentTime / player.duration)
                controlsView.setLeft(time: player.currentTime)

                animatableView.forEach {
                    $0.randomRotatingAnimation()
                }
            }

        }

        controlsView.pauseAction = { [weak self] in
            guard let self else { return }
            audioPlayer?.pause()
            timer?.invalidate()
        }

        controlsView.forwardAction = { [weak self] in
            guard let self else { return }
            audioPlayer?.currentTime = audioPlayer?.duration ?? 0
        }

        controlsView.backwardAction = { [weak self] in
            guard let self else { return }
            audioPlayer?.currentTime = 0
        }

        controlsView.setRight(time: audioPlayer?.duration ?? 0)
        controlsView.setLeft(time: 0)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        audioPlayer?.prepareToPlay()
    }

    override func willMove(toParent parent: UIViewController?) {
        if parent == nil {
            timer?.invalidate()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let colorTop =  UIColor(red: 0/255.0, green: 0/255.0, blue: 0.0/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 128/255.0, green: 0/255.0, blue: 128/255.0, alpha: 1.0).cgColor

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds

        self.view.layer.insertSublayer(gradientLayer, at:0)

        var imageNames = [
            "Rectangle1",
            "Rectangle2",
            "Rectangle3",

            "Solar1",
            "Solar2",
            "Solar3",

            "Spiral1",
            "Spiral2",
            "Spiral3",
        ]

        imageNames += imageNames
        imageNames += imageNames

        if animatableView.isEmpty && view.bounds.size != .zero {
            animatableView = imageNames.map { name in
                let view = Rotation3DView()
                view.image = UIImage(named: name)
                let size = CGFloat.random(in: 30...100)
                view.frame = .init(
                    origin: .init(
                        x: .random(in: 0...self.view.bounds.maxX),
                        y: .random(in: 0...self.view.bounds.maxY)
                    ),
                    size: .init(
                        width: size,
                        height: size
                    )
                )
                view.layer.zPosition = 500
                view.layer.masksToBounds = false

                self.view.addSubview(view)

                return view
            }
        }
    }

    @objc
    private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc
    private func didTapShare() {
        let objectsToShare = [url]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        present(activityVC, animated: true)
    }


    @objc
    private func didChangeProgress() {
        let progress = Double(progressSlider.value) * (audioPlayer?.duration ?? 0)
        audioPlayer?.currentTime = progress
        controlsView.setLeft(time: audioPlayer?.currentTime ?? 0)
    }
}

extension FinalVisulizerViewController: AVAudioPlayerDelegate {

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        timer?.invalidate()
        if player.currentTime == 0 {
            controlsView.setLeft(time: player.duration)
            progressSlider.value = 1
        }
        controlsView.stop()
    }
}


extension AVAudioFile {
    var duration: TimeInterval {
        let sampleRateSong = Double(processingFormat.sampleRate)
        let lengthSongSeconds = Double(length) / sampleRateSong
        return lengthSongSeconds
    }

}

extension AVAudioPlayerNode {
    var currentTime: TimeInterval{
        if let nodeTime = lastRenderTime,let playerTime = playerTime(forNodeTime: nodeTime) {
            return Double(playerTime.sampleTime) / playerTime.sampleRate
        }
        return 0
    }
}
