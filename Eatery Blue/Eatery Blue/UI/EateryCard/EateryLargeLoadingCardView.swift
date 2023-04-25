//
//  EateryLargeLoadingCardView.swift
//  Eatery Blue
//
//  Created by Antoinette Marie Torres on 4/25/23.
//

import UIKit

class EateryLargeLoadingCardView: UIView {
    
    let imageView = UIView() 
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpSelf()
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpSelf() {
        insetsLayoutMarginsFromSafeArea = false
        layoutMargins = .zero
        backgroundColor = UIColor.Eatery.gray00
    }
    
    private func setUpConstraints() {
        snp.makeConstraints { make in
            make.width.equalTo(snp.height).multipliedBy(343.0 / 216.0).priority(.required.advanced(by: -1))
        }
    }
}

