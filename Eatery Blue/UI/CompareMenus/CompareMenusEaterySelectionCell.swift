//
//  CompareMenusEaterySelectionCell.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi  on 3/2/24.
//

import EateryModel
import UIKit

class CompareMenusEaterySelectionCell: UITableViewCell {

    static let reuse = "CompareMenusEaterySelectionCellReuse"

    private let nameView = UILabel()
    private let checkView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(eatery: Eatery, filled: Bool, draggable: Bool) {
        nameView.text = eatery.name
        if filled {
            checkView.image = UIImage(named: "CheckboxFilled")
        } else {
            checkView.image = UIImage(named: "CheckboxUnfilled")
        }
        self.layoutIfNeeded()
        if draggable {
            nameView.snp.updateConstraints { make in
                make.leading.equalToSuperview().offset(32)
            }
        } else {
            nameView.snp.updateConstraints { make in
                make.leading.equalToSuperview()
            }
        }
        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()
        }
    }

    private func setUpSelf() {
        addSubview(nameView)
        addSubview(checkView)
    }

    private func setUpConstraints() {

        checkView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
        }

        nameView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalTo(checkView.snp.leading)
            make.centerY.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let reorderControl = subviews.first(where: { subview in
            type(of: subview).description() == "UITableViewCellReorderControl"
        }) {
            reorderControl.snp.remakeConstraints { make in
                make.leading.equalToSuperview()
                make.width.equalTo(24)
                make.height.equalToSuperview()
                make.centerY.equalToSuperview()
            }
        }
    }
}

