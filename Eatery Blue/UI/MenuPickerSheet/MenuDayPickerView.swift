//
//  MenuDayPickerView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/26/21.
//

import UIKit

class MenuDayPickerView: UIView {

    let stackView = UIStackView()
    private(set) var cells: [MenuDayPickerCell] = []

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
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(layoutMarginsGuide)
        }
    }

    func addCell(_ cell: MenuDayPickerCell) {
        stackView.addArrangedSubview(cell)
        cells.append(cell)
    }

}
