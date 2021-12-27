//
//  DayPickerView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/26/21.
//

import UIKit

class DayPickerView: UIView {

    let stackView = UIStackView()
    private(set) var cells: [DayPickerCell] = []

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
    }

    private func setUpStackView() {
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
    }

    private func setUpConstraints() {
        stackView.edges(to: layoutMarginsGuide)
    }

    func addCell(_ cell: DayPickerCell) {
        stackView.addArrangedSubview(cell)
        cells.append(cell)
    }

}
