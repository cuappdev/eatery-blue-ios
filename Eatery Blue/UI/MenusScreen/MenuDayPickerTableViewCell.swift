//
//  MenuDayPickerTableViewCell.swift
//  Eatery Blue
//
//  Created by Antoinette Marie Torres on 9/21/23.
//

import UIKit
import EateryModel

class MenuDayPickerTableViewCell: UITableViewCell {
    
  let dayPickerView = MenuDayPickerView()
  private var days: [Day] = []
    
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setState()
    addDayPickerView()
    contentView.addSubview(dayPickerView)
    dayPickerView.translatesAutoresizingMaskIntoConstraints = false
     
    NSLayoutConstraint.activate([
      dayPickerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      dayPickerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      dayPickerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
      dayPickerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    ])
  }
    
  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
    
  private func setState() {
    days = []
    for i in 0...6 {
      days.append(Day().advanced(by: i))
    }
  }
    
  private let weekdayFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = .eatery
      formatter.dateFormat = "EEE"
    return formatter
  }()
    
  private func addDayPickerView() {
    dayPickerView.layoutMargins = .zero
    for (i, day) in days.enumerated() {
      let cell = MenuDayPickerCell()
      cell.weekdayLabel.text = weekdayFormatter.string(from: day.date()).uppercased()
        cell.dayLabel.content.text = "\(day.day)"
//      cell.tap { [self] _ in
//        didTapDayPickerCellAt(at: i)
//      }
      dayPickerView.addCell(cell)
    }
    contentView.addSubview(dayPickerView)
  }
}
