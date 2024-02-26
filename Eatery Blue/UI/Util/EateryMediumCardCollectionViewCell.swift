//
//  ClearCollectionViewCell.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi  on 2/22/24.
//

import UIKit
import EateryModel

class EateryMediumCardCollectionViewCell: UICollectionViewCell {
        
    private let card: EateryCardVisualEffectView<EateryMediumCardContentView> = EateryCardVisualEffectView(content: EateryMediumCardContentView())

    static let reuse = "clear_collectionviewcell_reuse"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCard()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCard() {
        addSubview(card)
        card.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    public func configure(eatery: Eatery) {
        card.content.configure(eatery: eatery)
    }
}
