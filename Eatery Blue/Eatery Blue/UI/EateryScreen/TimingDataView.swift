//
//  TimingDataView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/23/21.
//

import UIKit

class TimingDataView: UIView {

    let stackView = UIStackView()

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
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = UIColor(named: "Gray00")?.cgColor
        stackView.layer.cornerRadius = 8

        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
    }

    private func setUpConstraints() {
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(layoutMarginsGuide)
        }
    }

    func addCellView(_ cellView: TimingCellView) {
        guard let firstCell = stackView.arrangedSubviews.first else {
            stackView.addArrangedSubview(cellView)
            return
        }

        let divider = VDivider()
        stackView.addArrangedSubview(divider)
        divider.snp.makeConstraints { make in
            make.height.equalTo(self).multipliedBy(0.5)
        }

        stackView.addArrangedSubview(cellView)
        cellView.snp.makeConstraints { make in
            make.width.equalTo(firstCell)
        }
    }

}
