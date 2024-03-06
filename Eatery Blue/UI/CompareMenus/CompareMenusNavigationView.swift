//
//  CompareMenusNavigationView.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi  on 3/4/24.
//

import EateryModel
import UIKit

class CompareMenusNavigationView: UIView {
    let backButton = ButtonView(content: UIImageView())
    private let titleLabel = UILabel()
    private let spacer = UIView()

    let prevEateryButton = ButtonView(content: UIImageView())
    let nextEateryButton = ButtonView(content: UIImageView())
    let eateryLabel = UILabel()
    let statusLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(eatery: Eatery) {
        eateryLabel.text = eatery.name
        statusLabel.attributedText = EateryFormatter.default.formatStatus(eatery.status)
    }

    private func setUpSelf() {
        backgroundColor = .white

        addSubview(backButton)
        setUpBackButton()

        addSubview(titleLabel)
        setUpTitleLabel()

        addSubview(spacer)
        spacer.backgroundColor = UIColor.Eatery.gray00

        addSubview(nextEateryButton)
        addSubview(prevEateryButton)
        setUpButtons()

        addSubview(eateryLabel)
        setUpEateryLabel()

        addSubview(statusLabel)
        setUpStatusLabel()
    }

    private func setUpBackButton() {
        backButton.content.image = UIImage(named: "ArrowLeft")
        backButton.shadowColor = UIColor.Eatery.black
        backButton.shadowOffset = CGSize(width: 0, height: 4)
        backButton.backgroundColor = .white
        backButton.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
    }

    private func setUpTitleLabel() {
        titleLabel.text = "Compare Menus"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = UIColor.Eatery.black
        titleLabel.textAlignment = .center
    }

    private func setUpButtons() {
        prevEateryButton.content.image = UIImage(systemName: "chevron.left")
        prevEateryButton.shadowColor = UIColor.Eatery.black
        prevEateryButton.content.tintColor = UIColor.Eatery.gray02
        prevEateryButton.shadowOffset = CGSize(width: 0, height: 4)
        prevEateryButton.backgroundColor = .white
        prevEateryButton.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        prevEateryButton.layer.zPosition = 99

        nextEateryButton.content.image = UIImage(systemName: "chevron.right")
        nextEateryButton.shadowColor = UIColor.Eatery.black
        nextEateryButton.content.tintColor = UIColor.Eatery.gray05
        nextEateryButton.shadowOffset = CGSize(width: 0, height: 4)
        nextEateryButton.backgroundColor = .white
        nextEateryButton.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        prevEateryButton.layer.zPosition = 99
    }

    private func setUpEateryLabel() {
        eateryLabel.text = "Eatery Name"
        eateryLabel.textColor = UIColor.Eatery.black
        eateryLabel.textAlignment = .center
    }

    private func setUpStatusLabel() {
        eateryLabel.text = "Status"
        statusLabel.textAlignment = .center
        statusLabel.font = .systemFont(ofSize: 14)
    }

    private func setUpConstraints() {
        backButton.snp.makeConstraints { make in
            make.leading.equalTo(layoutMarginsGuide.snp.leading)
            make.top.equalToSuperview()
            make.width.height.equalTo(40)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(backButton.snp.trailing).offset(8)
            make.top.centerX.equalToSuperview()
            make.trailing.lessThanOrEqualTo(layoutMarginsGuide.snp.trailing).inset(40)
        }

        spacer.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.width.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
        }

        prevEateryButton.snp.makeConstraints { make in
            make.leading.equalTo(layoutMarginsGuide.snp.leading)
            make.top.equalTo(spacer.snp.bottom).offset(12)
        }

        nextEateryButton.snp.makeConstraints { make in
            make.trailing.equalTo(layoutMarginsGuide.snp.trailing)
            make.top.equalTo(spacer.snp.bottom).offset(12)
        }

        eateryLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(spacer.snp.bottom).offset(10)
            make.leading.equalTo(prevEateryButton.snp.trailing)
            make.trailing.equalTo(nextEateryButton.snp.leading)
        }

        statusLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(eateryLabel.snp.bottom).offset(10)
        }
    }
}
