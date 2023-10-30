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
        titleLabel.textColor = UIColor.Eatery.black
    }

    private func setUpSubtitleLabel() {
        subtitleLabel.font = .preferredFont(for: .subheadline, weight: .semibold)
        subtitleLabel.textColor = UIColor.Eatery.gray05
    }

    private func setUpButtonImageView() {
        buttonImageView.image = UIImage(named: "Calendar 1")
        buttonImageView.isUserInteractionEnabled = true
    }

    private func setUpConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(layoutMarginsGuide)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.bottom.equalTo(layoutMarginsGuide)
        }

        buttonImageView.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(8)
            make.leading.equalTo(subtitleLabel.snp.trailing).offset(8)
            make.width.height.equalTo(40)
            make.trailing.centerY.equalTo(layoutMarginsGuide)
        }
    }

}
