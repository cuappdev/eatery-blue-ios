//
//  TabButtonView.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 11/11/24.
//

import UIKit

class TabButtonView: ButtonView<UIView> {

    // MARK: - Properties (View)

    private let container = UIView()
    private let label = UILabel()
    var delegate: TabButtonViewDelegate?

    // MARK: - Properties (Data)

    var selected = false {
        didSet {
            selected ? select() : deselect()
        }
    }

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

    required init?(coder: NSCoder) {
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

        self.content = container
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

protocol TabButtonViewDelegate {
    func tabButtonView(_ tabButtonView: TabButtonView, didSelect label: String)
}
