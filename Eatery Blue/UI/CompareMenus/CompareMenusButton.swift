//
//  CompareMenusButton.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi  on 3/1/24.
//

import UIKit

class CompareMenusButton: UIButton {

    private let openFrame = CGRect(x: 0, y: 0, width: 206, height: 56)
    private let closeFrame = CGRect(x: 0, y: 0, width: 56, height: 56)
    var isCollapsed = true

    private let button = UIButton()
    private let textView = UILabel()

    private var largeButtonCallback: ((UIButton) -> Void)?
    private var smallButtonCallback: ((UIButton) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpSelf() {
        frame = closeFrame
        backgroundColor = UIColor(named: "EateryBlue")
        layer.cornerRadius = frame.height / 2

        addSubview(button)
        setUpButton()

        addSubview(textView)
        setUpTextView()

        self.addTarget(self, action: #selector(largeButtonTouchUpInside), for: .touchUpInside)
        self.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        self.addTarget(self, action: #selector(buttonTouchUpOutside), for: .touchUpOutside)
    }

    private func setUpButton() {
        button.layer.frame = CGRect(x: 0, y: 0, width: openFrame.height, height: openFrame.height)
        button.backgroundColor = UIColor(named: "EateryBlue")
        button.setImage(UIImage(named: "CompareMenus"), for: .normal)
        button.layer.cornerRadius = button.frame.width / 2

        button.addTarget(self, action: #selector(smallButtonTouchUpInside), for: .touchUpInside)
        button.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUpOutside), for: .touchUpOutside)

    }

    private func setUpTextView() {
        textView.text = "Compare menus"
        textView.font = .systemFont(ofSize: 17, weight: .semibold)
        textView.textColor = .white
        textView.textAlignment = .center
        textView.layer.opacity = 0
    }

    private func setUpConstraints() {
        snp.makeConstraints { make in
            make.width.equalTo(closeFrame.width)
            make.height.equalTo(closeFrame.height)
        }

        button.snp.makeConstraints { make in
            make.width.equalTo(openFrame.height * 0.71)
            make.height.equalTo(openFrame.height * 0.71)
            make.centerX.equalTo(snp.right).inset(29)
            make.centerY.equalToSuperview()
        }

        textView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(18)
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
            toggleCollapse()
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

    private func toggleCollapse() {
        if isCollapsed {
            expand()
        } else {
            collapse()
        }
    }

    func expand() {
        isCollapsed = false
        snp.updateConstraints { make in
            make.width.equalTo(openFrame.width)
        }
        button.snp.updateConstraints { make in
            make.width.equalTo(openFrame.height * 0.71)
            make.height.equalTo(openFrame.height * 0.71)
            make.centerX.equalTo(snp.right).inset(29)
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self else { return }

            layoutIfNeeded()
            frame.size.width = self.openFrame.width
            textView.layer.opacity = 1

            button.layer.frame.size.width = openFrame.height * 0.71
            button.layer.frame.size.height = openFrame.height * 0.71
            button.backgroundColor = .white
            button.setImage(UIImage(named: "X"), for: .normal)
            button.layer.cornerRadius = button.frame.width / 2
        }
    }

    func collapse() {
        isCollapsed = true
        snp.updateConstraints { make in
            make.width.equalTo(closeFrame.width)
        }
        button.snp.updateConstraints { make in
            make.width.equalTo(openFrame.height)
            make.height.equalTo(openFrame.height)
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self else { return }

            layoutIfNeeded()
            frame.size.width = self.closeFrame.width
            textView.layer.opacity = 0

            button.layer.frame = CGRect(x: 0, y: 0, width: openFrame.height, height: openFrame.height)
            button.backgroundColor = UIColor(named: "EateryBlue")
            button.setImage(UIImage(named: "CompareMenus"), for: .normal)
            button.layer.cornerRadius = button.frame.width / 2
        }
    }

}
