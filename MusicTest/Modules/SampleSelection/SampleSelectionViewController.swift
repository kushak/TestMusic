//
//  SampleSelectionViewController.swift
//  MusicTest
//
//  Created by Oleg Shipulin on 01.11.2023.
//

import UIKit

protocol SampleSelectionOutput: AnyObject {
    func didSelectSamle(with url: URL)
}

final class SampleSelectionViewController: UIViewController {

    weak var output: SampleSelectionOutput?

    private let sampleSelectionService = SampleSelectionService()
    private let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()

        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing

        stackView.addArrangedSubview(
            createButton(
                withSystemImageName: "guitars.fill",
                title: "Гитара",
                urls: sampleSelectionService.getGuitars()
            )
        )
        stackView.addArrangedSubview(
            createButton(
                withSystemImageName: "oar.2.crossed",
                title: "Ударные",
                urls: sampleSelectionService.getDrums()
            )
        )
        stackView.addArrangedSubview(
            createButton(
                withSystemImageName: "wind",
                title: "Духовые",
                urls: sampleSelectionService.getWoodwinds()
            )
        )

        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate(
            [
                stackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
                stackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
                stackView.topAnchor.constraint(equalTo: view.topAnchor),
                stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ]
        )
    }

    private func createButton(
        withSystemImageName systemImageName: String,
        title: String,
        urls: [URL]
    ) -> SampleSelectionButton {
        let view = SampleSelectionButton()
        let samples = urls.map { String($0.lastPathComponent.split(separator: "." )[0]) }
        view.configure(
            with: .init(
                systemImageName: systemImageName,
                title: title,
                samles: samples,
                didSelectSample: { [weak self] index in
                    guard let self else { return }
                    output?.didSelectSamle(with: urls[index])
                }
            )
        )

        return view
    }
}
