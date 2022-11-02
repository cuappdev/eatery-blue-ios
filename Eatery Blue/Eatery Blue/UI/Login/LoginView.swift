//
//  LoginView.swift
//  Eatery Blue
//
//  Created by William Ma on 1/7/22.
//

import UIKit

class LoginView: UIView {

    private let stackView = UIStackView()
    let netIdTextField = UITextField()
    let passwordTextField = UITextField()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        addSubview(stackView)
        setUpStackView()
    }

    private func setUpStackView() {
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
    }

    func setCustomSpacing(_ spacing: CGFloat) {
        if let last = stackView.arrangedSubviews.last {
            stackView.setCustomSpacing(spacing, after: last)
        }
    }

    func addTitleLabel(_ text: String) {
        let titleLabel = UILabel()
        titleLabel.text = text
        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = UIColor.Eatery.blue

        stackView.addArrangedSubview(titleLabel)
    }

    func addSubtitleLabel(_ text: String) {
        let subtitleLabel = UILabel()
        subtitleLabel.text = text
        subtitleLabel.font = .preferredFont(for: .body, weight: .medium)
        subtitleLabel.textColor = UIColor.Eatery.gray06

        stackView.addArrangedSubview(subtitleLabel)
    }

    func addFieldTitleLabel(_ title: String) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(for: .body, weight: .semibold)
        titleLabel.textColor = UIColor.Eatery.black

        stackView.addArrangedSubview(titleLabel)
    }

    func addTextField(_ textField: UITextField) {
        let container = ContainerView(content: textField)
        container.backgroundColor = UIColor.Eatery.gray00
        container.cornerRadius = 8
        container.layoutMargins = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        container.tap { _ in
            textField.becomeFirstResponder()
        }
        stackView.addArrangedSubview(container)
    }

    func addCustomView(_ view: UIView) {
        stackView.addArrangedSubview(view)
    }

    private func setUpConstraints() {
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }

}
