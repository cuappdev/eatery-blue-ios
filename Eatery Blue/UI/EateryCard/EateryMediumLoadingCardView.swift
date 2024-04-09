//
//  EateryMediumLoadingCardView.swift
//  Eatery Blue
//
//  Created by Antoinette Marie Torres on 4/25/23.
//

import UIKit

class EateryMediumLoadingCardView: EateryCardShimmerView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpShimmerView(for: .Medium)
        startLoadingAnimation()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpConstraints() {
        snp.makeConstraints { make in
            make.width.equalTo(snp.height).multipliedBy(270.0 / 186.0).priority(.required.advanced(by: -1))
            make.height.equalTo(UIScreen.main.bounds.height/4.0 - 20)
        }
    }
}
