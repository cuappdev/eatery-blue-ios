//
//  EateryExpandableCardMenuCategoryView.swift
//  Eatery Blue
//
//  Created by Antoinette Marie Torres on 9/27/23.
//

import EateryModel
import SnapKit
import UIKit

class EateryExpandableCardMenuCategoryView: UIView {
    
    // MARK: - Properties
    
    private let categoryNameLabel = UILabel()
    private let foodItemLabel = UILabel()
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCategoryNameLabel()
        setupFoodItemLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - configure
    
    func configure(menuCategory: MenuCategory) {
        var foodItemString = ""
        menuCategory.items.forEach { item in
            foodItemString.append("\(item.name)\n")
        }
        
        foodItemLabel.text = String(foodItemString.dropLast(1))
        categoryNameLabel.text = menuCategory.category
    }
    
    // MARK: - Set Up Views
    
    private func setupCategoryNameLabel() {
        categoryNameLabel.textColor = UIColor.Eatery.black
        categoryNameLabel.font = UIFont.preferredFont(for: .title3, weight: .semibold)
        
        addSubview(categoryNameLabel)
        
        categoryNameLabel.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
        }
    }
    
    private func setupFoodItemLabel() {
        foodItemLabel.textColor = UIColor.Eatery.gray05
        foodItemLabel.font = UIFont.preferredFont(for: .footnote, weight: .regular)
        foodItemLabel.numberOfLines = 0
        
        addSubview(foodItemLabel)
        
        foodItemLabel.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(categoryNameLabel.snp.bottom).offset(8)
        }
    }
    
    func reset() {
        foodItemLabel.text = ""
        categoryNameLabel.text = ""
    }
    
}
