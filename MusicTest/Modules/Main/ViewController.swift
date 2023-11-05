//
//  ViewController.swift
//  MusicTest
//
//  Created by Oleg Shipulin on 31.10.2023.
//

import UIKit
import AVFAudio

final class ViewController: UIViewController {
    private let engine = AVAudioEngine()
    private let sampleSelectionViewController = SampleSelectionViewController()
    private let sampleSettingsViewController = SampleSettingsViewController()
    private lazy var visualizerViewContoller = VisualizerViewContoller(engine: engine)
    private lazy var layerListViewController = LayerListViewController(engine: engine)
    private lazy var recordControlsViewController = RecordControlsViewController(engine: engine)

    private lazy var layersButton: UIButton = {
        let button = UIButton()
        button.setTitle("  Слои", for: .normal)
        button.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        button.setImage(UIImage(systemName: "chevron.down"), for: .selected)
        button.tintColor = .darkText
        button.setTitleColor(.darkText, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.contentEdgeInsets = .init(top: 10, left: 20, bottom: 10, right: 20)
        button.addTarget(self, action: #selector(didTapLayers), for: .touchUpInside)

        return button
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setMode(.default)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            try audioSession.setCategory(.playAndRecord, mode: .default)

        } catch {
            print(error)
            print(error.localizedDescription)
        }

        addChildModule(sampleSettingsViewController)
        sampleSettingsViewController.output = self

        addChildModule(visualizerViewContoller)

        addChildModule(layerListViewController)
        layerListViewController.output = self
        layerListViewController.view.isHidden = true

        addChildModule(recordControlsViewController)
        recordControlsViewController.output = self

        addChildModule(sampleSelectionViewController)
        sampleSelectionViewController.output = self

        let views: [UIView] = [
            layersButton,
        ]

        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }


        NSLayoutConstraint.activate(
            [
                sampleSelectionViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
                sampleSelectionViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
                sampleSelectionViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                sampleSelectionViewController.view.heightAnchor.constraint(equalToConstant: 100),

                sampleSettingsViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
                sampleSettingsViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150),
                sampleSettingsViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
                sampleSettingsViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -160),

                layerListViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
                layerListViewController.view.topAnchor.constraint(equalTo: sampleSelectionViewController.view.bottomAnchor),// constant: -80),
                layerListViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -140),
                layerListViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),

                visualizerViewContoller.view.heightAnchor.constraint(equalToConstant: 40),
                visualizerViewContoller.view.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
                visualizerViewContoller.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
                visualizerViewContoller.view.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),

                layersButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
                layersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),

                recordControlsViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
                recordControlsViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            ]
        )
    }

    @objc private func didTapLayers() {
        if layerListViewController.view.isHidden {
            layersButton.backgroundColor = UIColor(
                red: 168/255,
                green: 219/255,
                blue: 16/255,
                alpha: 1
            )
        } else {
            layersButton.backgroundColor = .white
        }
        layersButton.isSelected.toggle()
        sampleSettingsViewController.view.isHidden = layerListViewController.view.isHidden
        layerListViewController.view.isHidden.toggle()
    }

    private func addChildModule(_ vc: UIViewController) {
        vc.willMove(toParent: self)
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        didMove(toParent: self)
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
    }
}

extension ViewController: SampleSelectionOutput {

    func didSelectSamle(with url: URL) {
        layerListViewController.add(sampleUrl: url, settings: sampleSettingsViewController.currentSettings)
    }
}

extension ViewController: SampleSettingsOutput {

    func didChange(settings: SampleSettings) {
        layerListViewController.update(settings: settings)
    }
}

extension ViewController: LayerListOutput {

    func didSelectSample(with settings: SampleSettings) {
        sampleSettingsViewController.configure(with: settings)
    }
}

extension ViewController: RecordControlsViewControllerOutput {

    func didRecordMic(url: URL) {
        layerListViewController.add(sampleUrl: url, settings: sampleSettingsViewController.currentSettings)
    }

    func didTapPlay() {
        layerListViewController.playAll()
    }

    func didTapStop() {
        layerListViewController.stopAll()
    }
}


