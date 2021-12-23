//
//  CafeMenuHeaderView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/23/21.
//

import UIKit

class CafeMenuHeaderView: UIView {

    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let buttonImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        addSubview(titleLabel)
        setUpTitleLabel()

        addSubview(subtitleLabel)
        setUpSubtitleLabel()

        addSubview(buttonImageView)
        setUpButtonImageView()
    }

    private func setUpTitleLabel() {
        titleLabel.font = .preferredFont(for: .title2, weight: .semibold)
        titleLabel.textColor = UIColor(named: "Black")
    }

    private func setUpSubtitleLabel() {
        subtitleLabel.font = .preferredFont(for: .subheadline, weight: .semibold)
        subtitleLabel.textColor = UIColor(named: "Gray05")
    }

    private func setUpButtonImageView() {
        buttonImageView.image = UIImage(named: "ButtonDownChevron")
    }

    private func setUpConstraints() {
        titleLabel.top(to: layoutMarginsGuide)
        titleLabel.leading(to: layoutMarginsGuide)
        titleLabel.trailingToLeading(of: buttonImageView)

        subtitleLabel.topToBottom(of: titleLabel, offset: 4)
        subtitleLabel.leading(to: layoutMarginsGuide)
        subtitleLabel.bottom(to: layoutMarginsGuide)
        subtitleLabel.trailingToLeading(of: buttonImageView)

        buttonImageView.width(40)
        buttonImageView.height(40)
        buttonImageView.trailing(to: layoutMarginsGuide)
        buttonImageView.centerYToSuperview()
    }

}
