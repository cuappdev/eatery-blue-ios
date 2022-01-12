//
//  IssueDescriptionView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/27/21.
//

import UIKit

class IssueDescriptionView: UIView {

    let placeholderLabel = UILabel()
    let textView = UITextView()

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

        addSubview(textView)
        setUpTextView()

        addSubview(placeholderLabel)
        setUpPlaceholderLabel()
    }

    private func setUpTextView() {
        textView.backgroundColor = .clear
        textView.textColor = UIColor(named: "Black")
        textView.font = .preferredFont(for: .subheadline, weight: .medium)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        textView.textContainer.lineFragmentPadding = 0
    }

    private func setUpPlaceholderLabel() {
        placeholderLabel.text = "Tell us what's wrong..."
        placeholderLabel.textColor = UIColor(named: "Gray05")
        placeholderLabel.font = .preferredFont(for: .subheadline, weight: .medium)
    }

    private func setUpConstraints() {
        textView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(8)
        }

        placeholderLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(8)
        }
    }

}
