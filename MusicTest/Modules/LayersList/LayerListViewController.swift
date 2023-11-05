//
//  LayerListViewController.swift
//  MusicTest
//
//  Created by Oleg Shipulin on 01.11.2023.
//

import UIKit
import AVFoundation

protocol LayerListOutput: AnyObject {
    func didSelectSample(with settings: SampleSettings)
}

private struct SampleInfo {
    let url: URL
    var settings: SampleSettings
    var isPaused: Bool
    var isLooped: Bool
    var isMuted: Bool
}

final class LayerListViewController: UIViewController {

    weak var output: LayerListOutput?
    private let engine: AVAudioEngine
    private var players: [String: AVAudioPlayerNode] = [:]
    private var sampleInfoList: [String: SampleInfo] = [:]
    private var cells: [String: LayerCellView] = [:]
    private let scrollView = UIScrollView()

    private var selectedSampleId: String? {
        didSet {
            cells.values.forEach { $0.backgroundColor = .white }
            guard let selectedSampleId else { return }
            cells[selectedSampleId]?.backgroundColor = UIColor(
                red: 168/255,
                green: 219/255,
                blue: 16/255,
                alpha: 1
            )
        }
    }

    private var stackView = UIStackView()

    init(engine: AVAudioEngine) {
        self.engine = engine
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.masksToBounds = false

        scrollView.indicatorStyle = .white
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 8
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate(
            [
                scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
                scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                scrollView.topAnchor.constraint(equalTo: view.topAnchor),

                stackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
                stackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),

                stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 20),
                stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -20),
                stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            ]
        )

        scrollView.transform = .init(rotationAngle: .pi)
        stackView.transform = .init(rotationAngle: .pi)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.verticalScrollIndicatorInsets = .init(top: 0, left: 0, bottom: 0, right: view.frame.width - 10)
    }

    func add(sampleUrl: URL, settings: SampleSettings) {
        let currentCount = sampleInfoList.values.filter { $0.url == sampleUrl }.count
        let sampleId = sampleUrl.absoluteString + ".\(currentCount)"

        sampleInfoList[sampleId] = .init(url: sampleUrl, settings: settings, isPaused: false, isLooped: true, isMuted: false)
        cells.forEach { id, cell in
            guard id != sampleId else { return }
            cell.displayPlayState(false)
        }

        players.forEach { id, player in
            guard id != sampleId else { return }
            player.pause()
        }

        let cell = LayerCellView()
        cell.configure(
            with: .init(
                title: String(sampleUrl.lastPathComponent.split(separator: ".")[0]) + ".\(currentCount)",
                didTapCell: { [weak self] in
                    guard let self else { return }
                    if selectedSampleId == sampleId {
                        selectedSampleId = nil
                    } else {
                        selectedSampleId = sampleId
                        guard let settings = self.sampleInfoList[sampleId]?.settings else { return }
                        output?.didSelectSample(with: settings)
                    }
                },
                didTapPlay: { [weak self] play in
                    guard let self else { return }
                    if play {
                        sampleInfoList[sampleId]?.isLooped = true
                        sampleInfoList[sampleId]?.isPaused = false
                        playSample(with: sampleUrl, id: sampleId, settings: settings)
                    } else {
                        players[sampleId]?.pause()
                        sampleInfoList[sampleId]?.isPaused = true
                    }
                },
                didTapMute: { [weak self] mute in
                    guard let self else { return }
                    if mute {
                        players[sampleId]?.volume = 0
                        sampleInfoList[sampleId]?.isMuted = true
                    } else {
                        players[sampleId]?.volume = settings.volume
                        sampleInfoList[sampleId]?.isMuted = false
                    }
                },
                didTapDelete: { [weak self] in
                    guard let self else { return }
                    sampleInfoList[sampleId]?.isLooped = false
                        stackView.removeArrangedSubview(cell)
                        cell.removeFromSuperview()

                    let transition: CATransition = CATransition()
                    transition.duration = 0.1
                    transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    transition.type = .fade
                    stackView.layer.add(transition, forKey: nil)

                    players[sampleId]?.stop()
                    players[sampleId] = nil
                    cells[sampleId] = nil
                    sampleInfoList[sampleId] = nil
                }
            )
        )

        cells[sampleId] = cell

        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .push
        cell.layer.add(transition, forKey: nil)
        stackView.addArrangedSubview(cell)
        stackView.layoutIfNeeded()

        playSample(with: sampleUrl, id: sampleId, settings: settings)
        sampleInfoList[sampleId]?.isLooped = false
    }

    func update(settings: SampleSettings) {
        guard let selectedSampleId else { return }
        sampleInfoList[selectedSampleId]?.settings = settings
        players[selectedSampleId]?.volume = settings.volume

        if sampleInfoList[selectedSampleId]?.isMuted == false {
            players[selectedSampleId]?.play()
        }
    }

    func playAll() {
        stopAll()
        sampleInfoList.forEach { id, info in
            sampleInfoList[id]?.isPaused = false
            sampleInfoList[id]?.isLooped = true
            cells[id]?.displayPlayState(true)
            playSample(with: info.url, id: id, settings: info.settings)
        }
    }

    func stopAll() {
        players.forEach { url, player in
            player.pause()
            sampleInfoList[url]?.isPaused = true
            cells[url]?.displayPlayState(false)
        }
    }

    private func playSample(
        with sampleUrl: URL,
        id: String,
        settings: SampleSettings
    ) {
        guard let file = try? AVAudioFile(forReading: sampleUrl) else { return }
        let player = AVAudioPlayerNode()
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: engine.mainMixerNode.outputFormat(forBus: 0))
        player.scheduleFile(file, at: nil) { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                guard self.sampleInfoList[id]?.isLooped == true else {
                    cells[id]?.displayPlayState(false)
                    return
                }

                let delay = self.sampleInfoList[id]?.settings.delay ?? settings.delay
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(delay * 1000))) { [weak self] in
                    guard let self, let info = sampleInfoList[id], !info.isPaused else { return }
                    playSample(with: sampleUrl, id: id, settings: info.settings)
                }
            }
        }

        if engine.isRunning == false {
            try! engine.start()
        }

        if let info = sampleInfoList[id], info.isMuted {
            player.volume = 0
        } else {
            player.volume = settings.volume
        }

        player.play()
        cells[id]?.displayPlayState(true)
        players[id] = player
    }
}
