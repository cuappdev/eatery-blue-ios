//
//  OnboardingFeatureView.swift
//  Eatery Blue
//
//  Created by William Ma on 1/4/22.
//

import UIKit

class OnboardingFeatureView: UIView {

    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
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
        addSubview(titleLabel)
        setUpTitleLabel()

        addSubview(subtitleLabel)
        setUpSubtitleLabel()

        addSubview(imageView)
        setUpImageView()
    }

    private func setUpTitleLabel() {
        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = UIColor.Eatery.blue
    }

    private func setUpSubtitleLabel() {
        subtitleLabel.font = .preferredFont(for: .body, weight: .medium)
        subtitleLabel.textColor = UIColor.Eatery.gray06
    }

    private func setUpImageView() {
        imageView.contentMode = .scaleAspectFit
    }

    private func setUpConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(layoutMarginsGuide)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(layoutMarginsGuide)
        }

        imageView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(layoutMarginsGuide)
            make.width.equalTo(imageView.snp.height).multipliedBy(9 / 19.5)
        }
    }

}
