//
//  ReportIssueButtonView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/27/21.
//

import UIKit

class ReportIssueButtonView: UIView {

    private let container = UIView()
    let imageView = UIImageView()
    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        backgroundColor = UIColor(named: "Gray00")
        layoutMargins = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)

        addSubview(container)
        setUpContainer()
    }

    private func setUpContainer() {
        container.addSubview(imageView)
        setUpImageView()

        container.addSubview(titleLabel)
        setUpTitleLabel()
    }

    private func setUpImageView() {
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "Report")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor(named: "Black")
    }

    private func setUpTitleLabel() {
        titleLabel.font = .preferredFont(for: .footnote, weight: .semibold)
        titleLabel.text = "Report an issue"
        titleLabel.textColor = UIColor(named: "Black")
    }

    private func setUpConstraints() {
        container.snp.makeConstraints { make in
            make.edges.equalTo(layoutMarginsGuide)
        }

        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(16)
            make.leading.centerY.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(4)
            make.top.trailing.bottom.equalToSuperview()
        }
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }

}
