//
//  PillFilterButtonView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import UIKit

class PillFilterButtonView: UIView {

    private let stackView = UIStackView()
    let label = UILabel()
    let imageView = UIImageView()

    private(set) var isHighlighted: Bool = false

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

        setHighlighted(isHighlighted)

        layoutMargins = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        insetsLayoutMarginsFromSafeArea = false
    }

    private func setUpStackView() {
        stackView.spacing = 2
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center

        stackView.addArrangedSubview(label)
        setUpLabel()

        stackView.addArrangedSubview(imageView)
        setUpImageView()
    }

    private func setUpLabel() {
        label.font = .preferredFont(for: .subheadline, weight: .semibold)
    }

    private func setUpImageView() {
        imageView.image = UIImage(named: "ChevronDown")?.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
    }

    private func setUpConstraints() {
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(layoutMarginsGuide)
        }

        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(16)
        }
    }

    func setHighlighted(_ isHighlighted: Bool) {
        self.isHighlighted = isHighlighted

        if isHighlighted {
            label.textColor = .white
            backgroundColor = UIColor(named: "Black")
            imageView.tintColor = .white
        } else {
            label.textColor = UIColor(named: "Black")
            backgroundColor = UIColor(named: "Gray00")
            imageView.tintColor = UIColor(named: "Black")
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }

}
