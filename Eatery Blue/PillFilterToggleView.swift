//
//  PillFilterToggleView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import UIKit

class PillFilterToggleView: UIView {

    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        addSubview(label)
        setUpLabel()

        setHighlighted(false)
    }

    private func setUpLabel() {
        label.font = .preferredFont(for: .subheadline, weight: .semibold)
    }

    private func setUpConstraints() {
        label.edgesToSuperview(insets: UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10))
    }

    func setHighlighted(_ isHighlighted: Bool) {
        if isHighlighted {
            label.textColor = .white
            backgroundColor = UIColor(named: "Black")
        } else {
            label.textColor = UIColor(named: "Black")
            backgroundColor = UIColor(named: "Gray00")
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }

}
