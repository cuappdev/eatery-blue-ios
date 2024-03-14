//
//  CompareMenusEaterySelectionCell.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi  on 3/2/24.
//

import EateryModel
import UIKit

class CompareMenusEaterySelectionCell: UIView {

    var filled: Bool = false
    let eatery: Eatery

    private let nameView = UILabel()
    private let checkView = UIImageView()

    init(eatery: Eatery) {
        self.eatery = eatery
        super.init(frame: .zero)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        checkView.image = UIImage(named: "CheckboxUnfilled")
        nameView.text = eatery.name
        
        addSubview(nameView)
        addSubview(checkView)
    }

    private func setUpConstraints() {
        snp.makeConstraints { make in
            make.height.equalTo(64)
        }

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

    func toggle() {
        if filled == false {
            checkView.image = UIImage(named: "CheckboxFilled")
        } else {
            checkView.image = UIImage(named: "CheckboxUnfilled")
        }
        filled = !filled
    }
}

