//
//  EateryExpandLoadingCardView.swift
//  Eatery Blue
//
//  Created by Antoinette Marie Torres on 9/24/23.
//

import UIKit

class EateryExpandLoadingCardView: EateryCardShimmerView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        insetsLayoutMarginsFromSafeArea = false
        layoutMargins = .zero
        setUpShimmerView(for: .Large)
        startLoadingAnimation()
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpConstraints() {
        snp.makeConstraints { make in
            make.width.equalTo(343)
            make.height.equalTo(66)
        }
    }

}
