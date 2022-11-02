//
//  SearchRecentItemView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/23/21.
//

import UIKit

class SearchRecentItemView: UIView {

    let imageView = UIImageView()
    let stackView = UIStackView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        addSubview(imageView)
        setUpImageView()

        addSubview(stackView)
        setUpStackView()
    }

    private func setUpImageView() {
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor.Eatery.blue
    }

    private func setUpStackView() {
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill

        stackView.addArrangedSubview(titleLabel)
        setUpTitleLabel()

        stackView.addArrangedSubview(subtitleLabel)
        setUpSubtitleLabel()
    }

    private func setUpTitleLabel() {
        titleLabel.textColor = UIColor.Eatery.blue
        titleLabel.font = .preferredFont(for: .body, weight: .medium)
    }

    private func setUpSubtitleLabel() {
        subtitleLabel.textColor = UIColor.Eatery.gray05
        subtitleLabel.font = .preferredFont(for: .caption1, weight: .medium)
    }

    private func setUpConstraints() {
        imageView.snp.makeConstraints { make in
            make.leading.centerY.equalTo(layoutMarginsGuide)
            make.width.height.equalTo(16)
        }

        stackView.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(8)
            make.top.trailing.bottom.equalToSuperview()
        }
    }

}
