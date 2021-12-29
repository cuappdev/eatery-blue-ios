//
//  WaitTimeCell.swift
//  Eatery Blue
//
//  Created by William Ma on 12/25/21.
//

import UIKit

class WaitTimeCell: UIView {

    let startTimeLabel = UILabel()
    let separator = VDivider()

    private let barHeightLayoutGuide = UILayoutGuide()
    let bar = UIView()

    private var barHeightConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        addSubview(separator)

        addSubview(startTimeLabel)
        setUpStartTimeLabel()

        addSubview(bar)
        setUpBar()
    }

    private func setUpStartTimeLabel() {
        startTimeLabel.font = .preferredFont(for: .caption2, weight: .semibold)
        startTimeLabel.textColor = UIColor(named: "Gray02")
        startTimeLabel.backgroundColor = .white
    }

    private func setUpBar() {
        bar.layer.cornerRadius = 8
        bar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bar.backgroundColor = UIColor(named: "EateryBlueMedium")
    }

    private func setUpConstraints() {
        separator.topToSuperview()
        separator.leadingToSuperview()
        separator.bottomToSuperview()

        startTimeLabel.topToSuperview(offset: 16)
        startTimeLabel.centerX(to: self, leadingAnchor)

        addLayoutGuide(barHeightLayoutGuide)
        barHeightLayoutGuide.topToBottom(of: startTimeLabel, offset: 8)
        barHeightLayoutGuide.edges(to: self, excluding: .top)

        bar.leadingToSuperview(offset: 4)
        bar.trailingToSuperview(offset: 4)
        bar.bottomToSuperview()
        barHeightConstraint = bar.height(to: barHeightLayoutGuide, multiplier: 0.5)
    }

    func setDatum(startTime: String, fraction: Double) {
        startTimeLabel.text = startTime

        barHeightConstraint?.isActive = false
        barHeightConstraint = bar.height(to: barHeightLayoutGuide, multiplier: max(0.05, min(0.95, fraction)))
    }

}
