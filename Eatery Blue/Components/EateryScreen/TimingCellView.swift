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

    required init?(coder: NSCoder) {
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
        titleLabel.edges(to: layoutMarginsGuide, excluding: .bottom)
        
        statusLabel.topToBottom(of: titleLabel, offset: 4)
        statusLabel.edges(to: layoutMarginsGuide, excluding: .top)
    }

}
