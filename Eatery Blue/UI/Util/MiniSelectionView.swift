//
//  MiniSelectionView.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 1/11/25.
//

import UIKit

class MiniSelectionView: UIView {
    // MARK: - Properties (view)

    private let stackView = UIStackView()

    // MARK: - Properties (data)

    private var buttons: [Int: (container: UIView, image: UIImageView)] = [:]
    /// Called when a button is tapped
    var onTap: ((Int) -> Void)? {
        didSet {
            for button in buttons {
                button.value.container.tap { [weak self] _ in
                    guard let self else { return }

                    selectButton(button.key)
                    onTap?(button.key)
                }
            }
        }
    }

    // MARK: - Init

    init() {
        super.init(frame: .zero)

        setUpSelf()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    override func layoutSubviews() {
        super.layoutSubviews()

        stackView.layer.cornerRadius = stackView.bounds.height / 2
    }

    private func setUpSelf() {
        addSubview(stackView)
        setUpStackView()

        setUpConstraints()
    }

    private func setUpStackView() {
        stackView.layer.masksToBounds = true
        stackView.axis = .horizontal
        stackView.spacing = 4
    }

    private func setUpConstraints() {
        stackView.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
        }
    }

    // MARK: - Actions

    /// Adds a button to the view, if the title isn't already in the view
    func addButton(_ identifier: Int, image: UIImage, padding: CGFloat = 0) {
        if buttons.keys.contains(identifier) { return }

        let imageView = UIImageView()
        imageView.image = image
            .withRenderingMode(.alwaysTemplate)

        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .Eatery.gray06

        let button = UIView()
        button.backgroundColor = .Eatery.gray00
        button.layoutMargins = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        button.tap { [weak self] _ in
            guard let self else { return }

            selectButton(identifier)
            onTap?(identifier)
        }

        button.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(button.layoutMargins)
        }

        stackView.addArrangedSubview(button)
        button.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(button.snp.height).multipliedBy(1.4)
        }

        buttons[identifier] = (container: button, image: imageView)
    }

    func selectButton(_ identifier: Int) {
        guard let button = buttons[identifier] else { return }

        for pair in buttons.values {
            pair.container.backgroundColor = .Eatery.gray00
            pair.image.tintColor = .Eatery.gray06
        }

        button.container.backgroundColor = .Eatery.blueLight
        button.image.tintColor = .Eatery.blue
    }
}
