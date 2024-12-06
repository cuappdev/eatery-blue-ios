//
//  CompareMenusNavigationView.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi  on 3/4/24.
//

import EateryModel
import UIKit

class CompareMenusNavigationView: UIView {

    // MARK: - Properties (view)

    let backButton = ButtonView(content: UIImageView())
    let editButton = ButtonView(content: UIImageView())
    private let titleLabel = UILabel()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setUpSelf() {
        backgroundColor = .white

        addSubview(backButton)
        setUpBackButton()

        addSubview(titleLabel)
        setUpTitleLabel()

        addSubview(editButton)
        setUpEditButton()
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
        titleLabel.font = .eateryNavigationBarTitleFont
        titleLabel.textColor = UIColor.Eatery.black
        titleLabel.textAlignment = .center
    }

    private func setUpEditButton() {
        editButton.content.image = UIImage(named: "Pencil")
        editButton.shadowColor = UIColor.Eatery.black
        editButton.shadowOffset = CGSize(width: 0, height: 4)
        editButton.backgroundColor = .white
        editButton.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }

    private func setUpConstraints() {
        backButton.snp.makeConstraints { make in
            make.leading.equalTo(layoutMarginsGuide.snp.leading)
            make.top.equalTo(layoutMarginsGuide.snp.top)
            make.width.height.equalTo(40)
        }
        
        editButton.snp.makeConstraints { make in
            make.trailing.equalTo(layoutMarginsGuide.snp.trailing)
            make.centerY.equalTo(backButton.snp.centerY)
            make.width.height.equalTo(36)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(backButton.snp.trailing).offset(8)
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton.snp.centerY)
            make.trailing.lessThanOrEqualTo(editButton.snp.trailing).inset(40)
        }
    }

}
