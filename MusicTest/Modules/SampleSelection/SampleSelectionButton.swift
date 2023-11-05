//
//  SampleSelectionButton.swift
//  MusicTest
//
//  Created by Oleg Shipulin on 01.11.2023.
//

import UIKit

private final class Label: UILabel {
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        super.drawText(in: rect.inset(by: insets))
    }
}

final class SampleSelectionButton: UIView {
    struct Model {
        let systemImageName: String
        let title: String
        let samles: [String]
        let didSelectSample: (Int) -> Void
    }

    private var selectedSample = 0
    private var didSelectSample: ((Int) -> Void)?
    private let backgroundView = UIView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let stackView = UIStackView()
    private var labels = [UILabel]()
    private var heightConstraint: NSLayoutConstraint?

    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        stackView.axis = .vertical
        stackView.alignment = .center
        imageView.contentMode = .center
        imageView.tintColor = .black
        stackView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = .white

        stackView.addArrangedSubview(imageView)
        backgroundView.addSubview(stackView)
        addSubview(titleLabel)
        addSubview(backgroundView)

        let heightConstraint = backgroundView.heightAnchor.constraint(equalToConstant: 60)
        self.heightConstraint = heightConstraint
        NSLayoutConstraint.activate(
            [
                widthAnchor.constraint(equalToConstant: 60),

                backgroundView.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 0),
                backgroundView.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: 0),
                backgroundView.topAnchor.constraint(equalTo: stackView.topAnchor),
                heightConstraint,

                stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
                stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
                stackView.topAnchor.constraint(equalTo: topAnchor),

                imageView.widthAnchor.constraint(equalToConstant: 60),
                imageView.heightAnchor.constraint(equalToConstant: 60),

                titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
                titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
                titleLabel.rightAnchor.constraint(equalTo: rightAnchor),
            ]
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let path = UIBezierPath(
            roundedRect: backgroundView.bounds,
            byRoundingCorners: .allCorners,
            cornerRadii: CGSize(width: 30, height: 30)
        )

        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        backgroundView.layer.mask = maskLayer
        backgroundView.layer.masksToBounds = true
    }

    func configure(with model: Model) {
        titleLabel.text = model.title
        imageView.image = UIImage(systemName: model.systemImageName)
        stackView.arrangedSubviews[1...].forEach { stackView.removeArrangedSubview($0) }

        model.samles.enumerated().forEach { index, sample in
            let label = Label()
            label.text = sample
            label.font = UIFont.systemFont(ofSize: 12)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            label.adjustsFontSizeToFitWidth = true
            if index == selectedSample {
                label.backgroundColor = .white
            }
            labels.append(label)
            stackView.addArrangedSubview(label)

            NSLayoutConstraint.activate(
                [
                    label.widthAnchor.constraint(equalToConstant: 60),
                    label.heightAnchor.constraint(equalToConstant: 30),
                ]
            )
        }

        didSelectSample = model.didSelectSample
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        expand()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        let labelIndex = labels.firstIndex(
            where: {
                $0.frame.contains(point)
            }
        )

        if let index = labelIndex {
            labels[selectedSample].backgroundColor = .clear
            selectedSample = index
            labels[index].backgroundColor = .white
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        didSelectSample?(selectedSample)
        self.collapse()
    }

    private var isExpanding = false
    private var needCollapse = false

    private func expand() {
        self.isExpanding = true
        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                guard let self else { return }
                heightConstraint?.constant = stackView.frame.height + 30
                layoutIfNeeded()
                backgroundView.backgroundColor = UIColor(
                    red: 168/255,
                    green: 219/255,
                    blue: 16/255,
                    alpha: 1
                )
            }
        ) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.isExpanding = false
                if self.needCollapse {
                    self.needCollapse = false
                    self.collapse()
                }

            }
        }
    }

    private func collapse() {
        if isExpanding {
            needCollapse = true
            return
        }
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.backgroundView.backgroundColor = .white
            self?.heightConstraint?.constant = 60
            self?.layoutIfNeeded()
        }
    }
}
