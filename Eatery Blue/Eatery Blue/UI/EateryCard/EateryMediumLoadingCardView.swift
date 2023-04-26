//
//  EateryMediumLoadingCardView.swift
//  Eatery Blue
//
//  Created by Antoinette Marie Torres on 4/25/23.
//

import UIKit

class EateryMediumLoadingCardView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.Eatery.gray00
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpConstraints() {
        snp.makeConstraints { make in
            make.width.equalTo(snp.height).multipliedBy(295.0 / 186.0).priority(.required.advanced(by: -1))
        }
    }
}

