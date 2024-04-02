//
//  CompareMenusButton.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi  on 3/1/24.
//

import UIKit

class CompareMenusButton: UIButton {

    // MARK: - Properties (data)

    private var largeButtonCallback: ((UIButton) -> Void)?
    private var smallButtonCallback: ((UIButton) -> Void)?
    private var isCollapsed = true

    // MARK: - Properties (view)

    private let button = UIButton()
    private let textView = UILabel()

    // MARK: - init

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setUpSelf() {
        backgroundColor = UIColor.Eatery.blue
        layer.cornerRadius = 56 / 2
        layer.shadowColor = UIColor.Eatery.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = .zero
        layer.shadowRadius = 2

        addSubview(button)
        setUpButton()

        addSubview(textView)
        setUpTextView()

        self.addTarget(self, action: #selector(largeButtonTouchUpInside), for: .touchUpInside)
        self.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        self.addTarget(self, action: #selector(buttonTouchUpOutside), for: .touchUpOutside)
    }

    private func setUpButton() {
        button.backgroundColor = UIColor.Eatery.blue
        button.setImage(UIImage(named: "CompareMenus"), for: .normal)
        button.layer.cornerRadius = 56 / 2

        button.addTarget(self, action: #selector(smallButtonTouchUpInside), for: .touchUpInside)
        button.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUpOutside), for: .touchUpOutside)
    }

    private func setUpTextView() {
        textView.text = "Compare menus"
        textView.font = .systemFont(ofSize: 14, weight: .semibold)
        textView.textColor = .white
        textView.textAlignment = .center
        textView.layer.opacity = 0
    }

    private func setUpConstraints() {
        snp.makeConstraints { make in
            make.size.equalTo(56)
        }

        button.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }

        textView.snp.makeConstraints { make in
            make.leading.equalTo(button.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
        }
    }

    func smallButtonPress(_ callback: ((UIButton) -> Void)?) {
        self.smallButtonCallback = callback
    }

    func largeButtonPress(_ callback: ((UIButton) -> Void)?) {
        self.largeButtonCallback = callback
    }

    @objc private func smallButtonTouchUpInside(_ sender: UIButton) {
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            guard let self else { return }
            smallButtonCallback?(sender)
        }

        UIView.animate(withDuration: 0.15, delay: 0.15, options: .beginFromCurrentState) { [weak self] in
            guard let self else { return }
            if isCollapsed {
                transform = .identity
            } else {
                sender.transform = .identity
            }
        }
    }

    @objc private func largeButtonTouchUpInside(_ sender: UIButton) {
        if isCollapsed { return }
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            guard let self else { return }
            largeButtonCallback?(sender)
        }

        UIView.animate(withDuration: 0.15, delay: 0.15, options: .beginFromCurrentState) {
            sender.transform = .identity
        }
    }

    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.15, delay: 0, options: .beginFromCurrentState) { [weak self] in
            guard let self else { return }
            if isCollapsed {
                transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            } else {
                sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
        }
    }

    @objc private func buttonTouchUpOutside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.15, delay: 0.15, options: .beginFromCurrentState) { [weak self] in
            guard let self else { return }
            if isCollapsed {
                transform = .identity
            } else {
                sender.transform = .identity
            }
        }
    }

    func toggle() {
        if isCollapsed {
            expand()
        } else {
            collapse()
        }
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
            UIView.animate(springDuration: 0.3, bounce: 0.3, initialSpringVelocity: 0.3, delay: 0, options: .curveEaseInOut) { [weak self] in
                guard let self else { return }
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
