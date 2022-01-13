//
//  MenuDayPickerCell.swift
//  Eatery Blue
//
//  Created by William Ma on 12/26/21.
//

import UIKit

class MenuDayPickerCell: UIView {

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
        weekdayLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(layoutMarginsGuide)
        }

        dayLabel.snp.makeConstraints { make in
            make.top.equalTo(weekdayLabel.snp.bottom).offset(16)
            make.bottom.equalTo(layoutMarginsGuide)
            make.centerX.equalTo(layoutMarginsGuide)
            make.width.height.equalTo(34)
        }
    }

}
