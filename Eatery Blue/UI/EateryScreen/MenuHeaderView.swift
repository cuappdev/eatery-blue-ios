//
//  MenuHeaderView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/23/21.
//

import UIKit

class MenuHeaderView: UIView {

    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let buttonImageView = UIImageView()
    let menuInaccuracyLabel = UILabel()

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

        addSubview(menuInaccuracyLabel)
        setUpMenuInaccuracyLabel()
    }

    private func setUpTitleLabel() {
        titleLabel.font = .preferredFont(for: .title2, weight: .semibold)
        titleLabel.textColor = UIColor.Eatery.black
    }

    private func setUpSubtitleLabel() {
        subtitleLabel.font = .preferredFont(for: .subheadline, weight: .semibold)
        subtitleLabel.textColor = UIColor.Eatery.gray05
    }

    private func setUpButtonImageView() {
        buttonImageView.image = UIImage(named: "EateryCalendar")
        buttonImageView.isUserInteractionEnabled = true
    }

    private func setUpMenuInaccuracyLabel() {
        menuInaccuracyLabel.text = "*Menus are based on Cornell Dining and are subject to change"
        menuInaccuracyLabel.font = .preferredFont(for: .caption2, weight: .semibold)
        menuInaccuracyLabel.textColor = UIColor.Eatery.gray05
    }

    private func setUpConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(layoutMarginsGuide)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(layoutMarginsGuide)
        }

        buttonImageView.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(8)
            make.leading.equalTo(subtitleLabel.snp.trailing).offset(8)
            make.width.height.equalTo(40)
            make.trailing.equalTo(layoutMarginsGuide)
            make.centerY.equalTo(layoutMarginsGuide).offset(-8)
        }

        menuInaccuracyLabel.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(12)
            make.leading.bottom.equalTo(layoutMarginsGuide)
        }
    }

}
