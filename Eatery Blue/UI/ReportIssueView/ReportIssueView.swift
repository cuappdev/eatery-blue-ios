//
//  ReportIssueView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/27/21.
//

import UIKit

class ReportIssueView: UIView {
    let stackView = UIStackView()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let button = ReportIssueButtonView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        addSubview(stackView)
        setUpStackView()
    }

    private func setUpStackView() {
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = 12

        stackView.addArrangedSubview(titleLabel)
        setUpTitleLabel()

        stackView.addArrangedSubview(descriptionLabel)
        setUpDescriptionLabel()

        stackView.addArrangedSubview(button)
        setUpButton()
    }

    private func setUpTitleLabel() {
        titleLabel.textColor = UIColor.Eatery.black
        titleLabel.font = .preferredFont(for: .body, weight: .semibold)
        titleLabel.text = "Make Eatery Better"
    }

    private func setUpDescriptionLabel() {
        descriptionLabel.textColor = UIColor.Eatery.gray05
        descriptionLabel.font = .preferredFont(for: .footnote, weight: .regular)
        descriptionLabel.text = "Help us make this info more accurate by letting us know what's wrong."
        descriptionLabel.numberOfLines = 0
    }

    private func setUpButton() {}

    private func setUpConstraints() {
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(layoutMarginsGuide)
        }
    }
}
