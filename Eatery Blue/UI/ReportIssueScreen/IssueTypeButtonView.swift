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
        label.top(to: layoutMarginsGuide)
        label.leading(to: layoutMarginsGuide)
        label.bottom(to: layoutMarginsGuide)

        imageView.leadingToTrailing(of: label, offset: 4)
        imageView.width(16)
        imageView.height(16)
        imageView.centerY(to: layoutMarginsGuide)
        imageView.trailing(to: layoutMarginsGuide)
        imageView.top(to: layoutMarginsGuide, relation: .equalOrGreater)
        imageView.bottom(to: layoutMarginsGuide, relation: .equalOrLess)
    }

}
