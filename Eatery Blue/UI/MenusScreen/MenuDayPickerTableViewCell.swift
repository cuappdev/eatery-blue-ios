//
//  MenuDayPickerTableViewCell.swift
//  Eatery Blue
//
//  Created by Antoinette Marie Torres on 9/21/23.
//

import EateryModel
import SnapKit
import UIKit

class MenuDayPickerTableViewCell: UITableViewCell {
    
    private let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = .eatery
        formatter.dateFormat = "EEE"
        return formatter
    }()
    
    class MenuChoice {

        let description: String
        let event: Event

        init(description: String, event: Event) {
            self.description = description
            self.event = event
        }

    }
    
    private let dayPickerView = MenuDayPickerView()
    
    private var days: [Day] = []
    private var selectedDayIndex: Int? = 0
    
    private var menuChoices: [MenuChoice] = []
    private var selectedMenuIndex: Int?
    
    weak var updateDateDelegate: UpdateDateDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        contentView.addSubview(dayPickerView)
        dayPickerView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(days: [Day]) {
        self.days = days
        
        // Reset data
        dayPickerView.resetCells()
        
        // Set new data
        addDayPickerView()
        updateDayPickerCellsFromState()
<<<<<<< HEAD
        
=======
>>>>>>> main
    }
    
    private func addDayPickerView() {
        dayPickerView.layoutMargins = .zero
        
        for (i, day) in days.enumerated() {
            let cell = MenuDayPickerCell()
            cell.weekdayLabel.text = weekdayFormatter.string(from: day.date()).uppercased()
            cell.dayLabel.content.text = "\(day.day)"
            cell.tap { [self] _ in
                didTapDayPickerCellAt(at: i)
            }
            dayPickerView.addCell(cell)
        }
        
        contentView.addSubview(dayPickerView)
    }

    private func updateDayPickerCellsFromState() {
        for (i, cell) in dayPickerView.cells.enumerated() {
            let day = days[i]

            let isSelected = i == selectedDayIndex
            let isToday = day == Day()

            if isToday {
                if isSelected {
                    cell.dayLabel.content.textColor = .white
                    cell.dayLabel.cornerRadiusView.backgroundColor = UIColor.Eatery.blue
                } else {
                    cell.dayLabel.content.textColor = UIColor.Eatery.blue
                    cell.dayLabel.cornerRadiusView.backgroundColor = nil
                }
            } else {
                if isSelected {
                    cell.dayLabel.content.textColor = .white
                    cell.dayLabel.cornerRadiusView.backgroundColor = UIColor.Eatery.black
                } else {
                    cell.dayLabel.content.textColor = UIColor.Eatery.black
                    cell.dayLabel.cornerRadiusView.backgroundColor = nil
                }
            }
        }
    }
    
    private func didTapDayPickerCellAt(at index: Int) {
        if selectedDayIndex == index { return }

        selectedDayIndex = index

        updateDateDelegate?.updateMenuDay(index: index)
        updateDayPickerCellsFromState()
    }
    
}
