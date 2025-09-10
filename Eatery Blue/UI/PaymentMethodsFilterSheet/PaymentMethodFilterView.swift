//
//  PaymentMethodFilterView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/24/21.
//

import UIKit

class PaymentMethodFilterView: UIView {
    let imageView = UIImageView()
    let label = UILabel()

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
        addSubview(imageView)
        setUpImageView()

        addSubview(label)
        setUpLabel()
    }

    private func setUpImageView() {}

    private func setUpLabel() {
        label.font = .preferredFont(for: .caption1, weight: .semibold)
        label.textAlignment = .center
    }

    private func setUpConstraints() {
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(64)
            make.top.equalTo(layoutMarginsGuide)
            make.centerX.equalToSuperview()
        }

        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalTo(layoutMarginsGuide)
        }
    }
}
