//
//  IssueTypeButtonView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/27/21.
//

import UIKit

class IssueTypeButtonView: UIView {

    let label = UILabel()
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
        backgroundColor = UIColor(named: "Gray00")
        layer.cornerRadius = 8

        addSubview(label)
        setUpLabel()

        addSubview(imageView)
        setUpImageView()
    }

    private func setUpLabel() {
        label.font = .preferredFont(for: .subheadline, weight: .medium)
    }

    private func setUpImageView() {
        imageView.image = UIImage(named: "ChevronDown")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor(named: "Gray05")
    }

    private func setUpConstraints() {
        label.snp.makeConstraints { make in
            make.top.leading.bottom.equalTo(layoutMarginsGuide)
        }

        imageView.snp.makeConstraints { make in
            make.leading.equalTo(label.snp.trailing).offset(4)
            make.width.height.equalTo(16)
            make.centerY.trailing.equalTo(layoutMarginsGuide)
            make.top.greaterThanOrEqualTo(layoutMarginsGuide)
        }
    }

}
