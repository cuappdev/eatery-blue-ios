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
    let buttonView = UIView()
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

        addSubview(buttonView)
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
        buttonView.backgroundColor = UIColor.Eatery.gray00
        buttonView.layer.cornerRadius = 21
        buttonView.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 16)

        let titleLabel = UILabel()
        titleLabel.text = "Change Date"
        titleLabel.font = .preferredFont(for: .subheadline, weight: .semibold)
        titleLabel.textColor = UIColor.Eatery.black

        buttonView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.trailing.equalTo(buttonView.layoutMarginsGuide)
            make.centerY.equalTo(buttonView)
        }

        let imageView = UIImageView()
        imageView.image = UIImage(named: "EateryCalendar")

        buttonView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.leading.equalTo(buttonView.layoutMarginsGuide)
            make.centerY.equalTo(buttonView)
        }

        buttonView.isUserInteractionEnabled = true
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

        buttonView.snp.makeConstraints { make in
            make.trailing.equalTo(layoutMarginsGuide)
            make.top.equalTo(layoutMarginsGuide).offset(8)
            make.height.equalTo(42)
            make.width.equalTo(156)
        }

        menuInaccuracyLabel.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(12)
            make.leading.bottom.equalTo(layoutMarginsGuide)
        }
    }

}
