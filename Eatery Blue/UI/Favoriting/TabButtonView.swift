//
//  TabButtonView.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 11/11/24.
//

import UIKit

class TabButtonView: ButtonView<UIView> {
    // MARK: - Properties (view)

    private let container = UIView()
    private let label = UILabel()

    // MARK: - Properties (data)

    /// Whether or not the button is selected
    var selected = false {
        didSet {
            selected ? select() : deselect()
        }
    }

    /// TabButtonDelegate responsible for handling selection of this TabButtonView
    var delegate: TabButtonViewDelegate?
    /// The text to be displayed on this TabButtonView
    var text = "" {
        didSet {
            label.text = text
        }
    }

    // MARK: - Init

    init() {
        super.init(content: UIView())
        setUpSelf()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    override func buttonPress(_ callback: ((UIButton) -> Void)?) {
        super.buttonPress { [weak self] btn in
            guard let self else { return }
            selected = true
            delegate?.tabButtonView(self, didSelect: text)
            callback?(btn)
        }
    }

    private func setUpSelf() {
        container.addSubview(label)
        setUpLabel()

        content = container
        setUpContainer()

        setUpConstraints()
    }

    private func setUpLabel() {
        label.font = .systemFont(ofSize: 14, weight: .medium)
    }

    private func setUpContainer() {
        container.layer.shadowColor = UIColor.lightGray.cgColor
        container.layer.shadowRadius = 0
        container.layer.shadowOpacity = 0.4
        container.layer.shadowOffset = CGSize(width: 0, height: 0)

        container.layer.cornerRadius = 9
        container.layer.borderWidth = 1
    }

    private func setUpConstraints() {
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func select() {
        container.backgroundColor = .white
        label.textColor = .Eatery.blue
        container.layer.borderColor = UIColor.Eatery.blue.cgColor
        container.layer.shadowRadius = 6
    }

    private func deselect() {
        container.backgroundColor = .Eatery.offWhite
        label.textColor = .Eatery.gray05
        container.layer.borderColor = UIColor.Eatery.gray02.cgColor
        container.layer.shadowRadius = 0
    }
}

protocol TabButtonViewDelegate: AnyObject {
    func tabButtonView(_ tabButtonView: TabButtonView, didSelect label: String)
}
