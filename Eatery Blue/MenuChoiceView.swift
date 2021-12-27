//
//  MenuChoiceView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/26/21.
//

import UIKit

class MenuChoiceView: UIView {

    let descriptionLabel = UILabel()
    let timeLabel = UILabel()
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        addSubview(descriptionLabel)
        setUpDescriptionLabel()

        addSubview(timeLabel)
        setUpTimeLabel()

        addSubview(imageView)
        setUpImageView()
    }

    private func setUpDescriptionLabel() {
        descriptionLabel.font = .preferredFont(for: .body, weight: .semibold)
        descriptionLabel.textColor = UIColor(named: "Black")
    }

    private func setUpTimeLabel() {
        timeLabel.font = .preferredFont(for: .caption1, weight: .semibold)
        timeLabel.textColor = UIColor(named: "Gray05")
    }

    private func setUpImageView() {
    }

    private func setUpConstraints() {
        descriptionLabel.top(to: layoutMarginsGuide)
        descriptionLabel.leading(to: layoutMarginsGuide)
        descriptionLabel.trailingToLeading(of: imageView)

        timeLabel.topToBottom(of: descriptionLabel, offset: 4)
        timeLabel.leading(to: layoutMarginsGuide)
        timeLabel.bottom(to: layoutMarginsGuide)
        timeLabel.trailingToLeading(of: imageView)

        imageView.centerY(to: layoutMarginsGuide)
        imageView.trailing(to: layoutMarginsGuide)
        imageView.width(24)
        imageView.height(24)
    }

}
