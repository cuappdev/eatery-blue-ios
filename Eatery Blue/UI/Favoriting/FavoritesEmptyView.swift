//
//  FavoritesEmptyView.swift
//  Eatery Blue
//
//  Created by Arielle Nudelman on 10/14/26.
//

import SnapKit
import UIKit

class FavoritesEmptyView: UIView {
    // MARK: - Properties (view)

    private let imageView = UIImageView()
    private let messageLabel = UILabel()
    private let stackView = UIStackView()
    private var centerYConstraint: Constraint?

    // MARK: - Init

    init(message: String) {
        super.init(frame: .zero)
        messageLabel.text = message
        setUpSelf()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Set Up

    private func setUpSelf() {
        backgroundColor = UIColor.Eatery.surface
        isUserInteractionEnabled = false

        addSubview(stackView)
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16

        imageView.image = UIImage(named: "Eatery")
        imageView.contentMode = .scaleAspectFit
        stackView.addArrangedSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(72)
        }

        messageLabel.font = .systemFont(ofSize: 18, weight: .medium)
        messageLabel.textColor = UIColor.Eatery.primaryText
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        stackView.addArrangedSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.width.equalTo(208)
        }

        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(208)
            centerYConstraint = make.centerY.equalToSuperview().constraint
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let window, bounds.height > 0 else { return }
        let screenCenter = convert(CGPoint(x: window.bounds.midX, y: window.bounds.midY), from: nil)
        let offset = screenCenter.y - bounds.midY
        centerYConstraint?.update(offset: offset)
    }
}
