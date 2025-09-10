//
//  TimingCellView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/23/21.
//

import UIKit

class TimingCellView: UIView {
    let titleLabel = UILabel()
    let statusLabel = UILabel()

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
        addSubview(titleLabel)
        titleLabel.font = .preferredFont(for: .caption1, weight: .semibold)
        titleLabel.textAlignment = .center

        addSubview(statusLabel)
        statusLabel.font = .preferredFont(for: .subheadline, weight: .semibold)
        statusLabel.textAlignment = .center
    }

    private func setUpConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(layoutMarginsGuide)
        }

        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.bottom.equalTo(layoutMarginsGuide)
        }
    }
}
