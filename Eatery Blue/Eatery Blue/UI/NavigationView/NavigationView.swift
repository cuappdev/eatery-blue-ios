//
//  NavigationView.swift
//  Eatery Blue
//
//  Created by William Ma on 1/8/22.
//

import UIKit

class NavigationView: UIView {

    let normalNavigationBar = UIView()
    let leftButtons = UIStackView()
    let titleLabel = UILabel()
    let rightButtons = UIStackView()

    let largeTitleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        addSubview(normalNavigationBar)
        setUpNormalNavigationBar()

        addSubview(largeTitleLabel)
        setUpLargeTitleLabel()
    }

    private func setUpNormalNavigationBar() {
        normalNavigationBar.addSubview(leftButtons)
        setUpLeftButtons()

        normalNavigationBar.addSubview(titleLabel)
        setUpTitleLabel()

        normalNavigationBar.addSubview(rightButtons)
        setUpRightButtons()
    }

    private func setUpLeftButtons() {
        leftButtons.axis = .horizontal
        leftButtons.alignment = .fill
        leftButtons.distribution = .fillEqually
        leftButtons.spacing = 8
    }

    private func setUpRightButtons() {
        rightButtons.axis = .horizontal
        rightButtons.alignment = .fill
        rightButtons.distribution = .fillEqually
        rightButtons.spacing = 8
    }

    private func setUpTitleLabel() {
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
    }

    private func setUpLargeTitleLabel() {
        largeTitleLabel.font = .systemFont(ofSize: 34, weight: .bold)
    }

    private func setUpConstraints() {
        normalNavigationBar.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.top.leading.trailing.equalTo(layoutMarginsGuide)
            make.bottom.lessThanOrEqualToSuperview()
        }

        leftButtons.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(leftButtons.snp.trailing).offset(8)
            make.top.bottom.centerX.equalToSuperview()
            make.trailing.lessThanOrEqualTo(rightButtons.snp.leading).offset(-8)
        }
        titleLabel.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultHigh - 1, for: .horizontal)

        rightButtons.snp.makeConstraints { make in
            make.top.trailing.bottom.equalToSuperview()
        }

        largeTitleLabel.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(layoutMarginsGuide)
        }
        largeTitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    func computeExpandedHeight() -> CGFloat {
        class Delegate: NSObject, UINavigationBarDelegate {
            func position(for bar: UIBarPositioning) -> UIBarPosition {
                .topAttached
            }
        }

        let dummyNavigationBar = UINavigationBar()
        dummyNavigationBar.prefersLargeTitles = true

        // As of iOS 15, the navigation bar changes its height by 2px whether it is top or topAttached
        let delegate = Delegate()
        dummyNavigationBar.delegate = delegate

        // Fix a font so that the height does not change based on
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .red
        appearance.titleTextAttributes = [.font: UIFont.eateryNavigationBarTitleFont]
        appearance.largeTitleTextAttributes = [.font: UIFont.eateryNavigationBarLargeTitleFont]
        dummyNavigationBar.standardAppearance = appearance
        dummyNavigationBar.scrollEdgeAppearance = appearance

        let item = UINavigationItem(title: "Dummy Navigation Bar")
        item.largeTitleDisplayMode = .always
        dummyNavigationBar.items = [item]

        addSubview(dummyNavigationBar)

        // If you want to see what the dummy navigation bar looks like attached to the view, comment the line below.
        defer { dummyNavigationBar.removeFromSuperview() }

        dummyNavigationBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(safeAreaLayoutGuide)
        }

        dummyNavigationBar.layoutIfNeeded()
        return safeAreaInsets.top + dummyNavigationBar.frame.height
    }

    func computeNormalHeight() -> CGFloat {
        return systemLayoutSizeFitting(
            CGSize(width: bounds.width, height: 0),
            withHorizontalFittingPriority: .defaultLow,
            verticalFittingPriority: .defaultHigh
        ).height
    }

    func setLeftButtons(_ buttons: [UIView]) {
        for view in leftButtons.arrangedSubviews {
            view.removeFromSuperview()
        }

        for button in buttons {
            leftButtons.addArrangedSubview(button)
        }
    }

    func setRightButtons(_ buttons: [UIView]) {
        for view in rightButtons.arrangedSubviews {
            view.removeFromSuperview()
        }

        for button in buttons {
            rightButtons.addArrangedSubview(button)
        }
    }

}
