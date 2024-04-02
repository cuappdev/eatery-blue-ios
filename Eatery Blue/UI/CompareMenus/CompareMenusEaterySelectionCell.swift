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
                make.trailing.equalToSuperview().offset(32)
            }
        } else {
            nameView.snp.updateConstraints { make in
                make.trailing.equalToSuperview()
            }
        }
        UIView.animate(withDuration: 0.1) { [weak self] in
            guard let self else { return }
            self.layoutIfNeeded()
        }
    }

    private func setUpSelf() {
        addSubview(nameView)
        addSubview(checkView)
    }

    private func setUpConstraints() {
        checkView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
        }

        nameView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.leading.equalTo(checkView.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let reorderControl = subviews.first(where: { subview in
            type(of: subview).description() == "UITableViewCellReorderControl"
        }) {
            reorderControl.snp.remakeConstraints { make in
                make.trailing.equalToSuperview()
                make.leading.equalTo(self.snp.trailing).inset(24)
                make.height.equalToSuperview()
                make.centerY.equalToSuperview()
            }
        }
    }
}

