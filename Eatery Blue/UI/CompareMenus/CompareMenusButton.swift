//
//  CompareMenusButton.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi  on 3/1/24.
//

import UIKit

class CompareMenusButton: UIButton {
    // MARK: - Properties (data)

    private var buttonCallback: ((UIButton) -> Void)?
    private var isCollapsed: Bool = true

    // MARK: - Properties (view)

    private let compareImageView = UIImageView()
    private let textView = UILabel()

    // MARK: - init

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setUpSelf() {
        backgroundColor = UIColor.Eatery.blue
        layer.cornerRadius = 56 / 2
        layer.shadowColor = UIColor.Eatery.primaryText.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = .zero
        layer.shadowRadius = 2

        addSubview(compareImageView)
        setUpCompareImageView()

        addSubview(textView)
        setUpTextView()

        addTarget(self, action: #selector(buttonTouchUpInside), for: .touchUpInside)
        addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        addTarget(self, action: #selector(buttonTouchUpOutside), for: .touchUpOutside)
    }

    private func setUpCompareImageView() {
        compareImageView.backgroundColor = UIColor.Eatery.blue
        compareImageView.image = UIImage(named: "CompareMenus")
        compareImageView.layer.cornerRadius = 56 / 2
    }

    private func setUpTextView() {
        textView.text = "Compare menus"
        textView.font = .systemFont(ofSize: 14, weight: .semibold)
        textView.textColor = UIColor.Eatery.default00
        textView.textAlignment = .center
        textView.layer.opacity = 0
    }

    private func setUpConstraints() {
        snp.makeConstraints { make in
            make.size.equalTo(56)
        }

        compareImageView.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }

        textView.snp.makeConstraints { make in
            make.leading.equalTo(compareImageView.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
        }
    }

    func buttonPress(_ callback: ((UIButton) -> Void)?) {
        buttonCallback = callback
    }

    @objc private func buttonTouchUpInside(_ sender: UIButton) {
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            guard let self else { return }

            buttonCallback?(sender)
        }

        UIView.animate(withDuration: 0.15, delay: 0, options: .beginFromCurrentState) {
            sender.transform = .identity
        }
    }

    @objc private func buttonTouchDown(_: UIButton) {
        UIView.animate(withDuration: 0.15, delay: 0, options: .beginFromCurrentState) { [weak self] in
            guard let self else { return }

            let transformPercentage = isCollapsed ? 0.9 : 0.95
            transform = CGAffineTransform(scaleX: transformPercentage, y: transformPercentage)
        }
    }

    @objc private func buttonTouchUpOutside(_: UIButton) {
        UIView.animate(withDuration: 0.15, delay: 0, options: .beginFromCurrentState) { [weak self] in
            guard let self else { return }

            transform = .identity
        }
    }

    func toggle() {
        isCollapsed ? expand() : collapse()
    }

    func expand() {
        isCollapsed = false
        snp.updateConstraints { make in
            make.width.equalTo(178)
        }

        animate { [weak self] in
            guard let self else { return }

            textView.layer.opacity = 1
            self.superview?.layoutIfNeeded()
        }
    }

    func collapse() {
        isCollapsed = true
        snp.updateConstraints { make in
            make.width.equalTo(56)
        }

        animate { [weak self] in
            guard let self else { return }

            textView.layer.opacity = 0
            self.superview?.layoutIfNeeded()
        }
    }

    private func animate(_ uiUpdates: (() -> Void)?) {
        if #available(iOS 17.0, *) {
            UIView.animate(
                springDuration: 0.3,
                bounce: 0.3,
                initialSpringVelocity: 0.3,
                delay: 0,
                options: .curveEaseInOut
            ) {
                uiUpdates?()
            }
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) { [weak self] in
                guard let self else { return }

                uiUpdates?()
                self.layoutIfNeeded()
            }
        }
    }
}
