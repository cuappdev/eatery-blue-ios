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
    let changeDateButton = PillButtonView()
    let buttonLabel = UILabel()
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

        addSubview(changeDateButton)
        setUpButtonImageView()

        addSubview(menuInaccuracyLabel)
        setUpMenuInaccuracyLabel()
    }

    private func setUpTitleLabel() {
        titleLabel.font = .preferredFont(for: .largeTitle, weight: .bold)
        titleLabel.textColor = UIColor.Eatery.black
    }

    private func setUpSubtitleLabel() {
        subtitleLabel.font = .preferredFont(for: .subheadline, weight: .semibold)
        subtitleLabel.textColor = UIColor.Eatery.gray05
    }

    private func setUpButtonImageView() {
//        buttonImageView.image = UIImage(named: "EateryCalendar")
//        buttonImageView.isUserInteractionEnabled = true
        changeDateButton.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        changeDateButton.backgroundColor = UIColor.Eatery.gray00
        changeDateButton.imageView.image = UIImage(named: "EateryCalendar")
        changeDateButton.imageView.tintColor = UIColor.Eatery.black
        changeDateButton.titleLabel.textColor = UIColor.Eatery.black
        changeDateButton.titleLabel.text = "Change Date"
        changeDateButton.titleLabel.font = .preferredFont(for: .caption1, weight: .semibold)
        changeDateButton.isUserInteractionEnabled = true
        
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

        changeDateButton.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(8)
            make.leading.equalTo(subtitleLabel.snp.trailing).offset(8)
            make.height.equalTo(36)
            make.width.equalTo(136)
            make.trailing.equalTo(layoutMarginsGuide)
            make.centerY.equalTo(layoutMarginsGuide).offset(-8)
        }

        menuInaccuracyLabel.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(12)
            make.leading.bottom.equalTo(layoutMarginsGuide)
        }
    }

}
