//
//  DayPickerCell.swift
//  Eatery Blue
//
//  Created by William Ma on 12/26/21.
//

import UIKit

class DayPickerCell: UIView {

    let weekdayLabel = UILabel()
    let dayLabel = ContainerView(pillContent: UILabel())

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        addSubview(weekdayLabel)
        setUpWeekdayLabel()

        addSubview(dayLabel)
        setUpDayLabel()
    }

    private func setUpWeekdayLabel() {
        weekdayLabel.font = .preferredFont(for: .caption1, weight: .semibold)
        weekdayLabel.textColor = UIColor(named: "Gray05")
        weekdayLabel.textAlignment = .center
    }

    private func setUpDayLabel() {
        dayLabel.content.font = .preferredFont(for: .body, weight: .regular)
        dayLabel.content.textAlignment = .center
    }

    private func setUpConstraints() {
        weekdayLabel.edges(to: layoutMarginsGuide, excluding: .bottom)

        dayLabel.topToBottom(of: weekdayLabel, offset: 16)
        dayLabel.bottom(to: layoutMarginsGuide)
        dayLabel.centerXToSuperview()
        dayLabel.width(34)
        dayLabel.height(34)
    }

}
