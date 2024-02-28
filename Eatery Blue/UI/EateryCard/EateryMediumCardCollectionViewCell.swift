//
//  EateryMediumCardCollectionViewCell.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi  on 2/22/24.
//

import EateryModel
import UIKit

class EateryMediumCardCollectionViewCell: UICollectionViewCell {
        
    private let card: EateryCardVisualEffectView<EateryMediumCardContentView> = EateryCardVisualEffectView(content: EateryMediumCardContentView())

    static let reuse = "EateryMediumCardCollectionViewCellReuse"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCard()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCard() {
        addSubview(card)
        card.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    public func configure(eatery: Eatery) {
        card.content.configure(eatery: eatery)
    }
}
