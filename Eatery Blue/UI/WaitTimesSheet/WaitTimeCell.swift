//
//  WaitTimeCell.swift
//  Eatery Blue
//
//  Created by William Ma on 12/25/21.
//

import SnapKit
import UIKit

class WaitTimeCell: UIView {

    let startTimeLabel = UILabel()
    let separator = VDivider()

    private let barHeightLayoutGuide = UILayoutGuide()
    let bar = UIView()

    private var barHeightConstraint: Constraint?

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
        startTimeLabel.textColor = UIColor.Eatery.gray02
        startTimeLabel.backgroundColor = .white
    }

    private func setUpBar() {
        bar.layer.cornerRadius = 8
        bar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bar.backgroundColor = UIColor.Eatery.blueMedium
    }

    private func setUpConstraints() {
        separator.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
        }

        startTimeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.centerX.equalTo(snp.leading)
        }

        addLayoutGuide(barHeightLayoutGuide)
        barHeightLayoutGuide.snp.makeConstraints { make in
            make.top.equalTo(startTimeLabel.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }

        bar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(4)
            make.bottom.equalToSuperview()
            barHeightConstraint = make.height.equalTo(barHeightLayoutGuide).multipliedBy(0.5).constraint
        }

//        separator.topToSuperview()
//        separator.leadingToSuperview()
//        separator.bottomToSuperview()
//
//        startTimeLabel.topToSuperview(offset: 16)
//        startTimeLabel.centerX(to: self, leadingAnchor)
//
//        addLayoutGuide(barHeightLayoutGuide)
//        barHeightLayoutGuide.topToBottom(of: startTimeLabel, offset: 8)
//        barHeightLayoutGuide.edges(to: self, excluding: .top)
//
//        bar.leadingToSuperview(offset: 4)
//        bar.trailingToSuperview(offset: 4)
//        bar.bottomToSuperview()
//        barHeightConstraint = bar.height(to: barHeightLayoutGuide, multiplier: 0.5)
    }

    func setDatum(startTime: String, fraction: Double) {
        startTimeLabel.text = startTime

        barHeightConstraint?.deactivate()
        bar.snp.makeConstraints { make in
            barHeightConstraint = make.height.equalTo(barHeightLayoutGuide).multipliedBy(max(0, min(1, fraction))).constraint
        }
    }

}
