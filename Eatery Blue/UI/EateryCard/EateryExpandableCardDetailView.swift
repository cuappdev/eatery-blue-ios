//
//  EateryExpandableCardDetailView.swift
//  Eatery Blue
//
//  Created by Antoinette Marie Torres on 9/23/23.
//

import EateryModel
import SnapKit
import UIKit

class EateryExpandableCardDetailView: UIView {
    
    // MARK: - Properties
    
    private let menuCategoryStackView = UIStackView()
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupMenuCategoryStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - configure
    
    func configure(eatery: Eatery) {
        switch eatery.status {
        case .closed:
            break
        case .closingSoon(let event):
            menuCategoryStackView.addArrangedSubview(HDivider())
            addMenuCategories(event: event)
        case .open(let event):
            menuCategoryStackView.addArrangedSubview(HDivider())
            addMenuCategories(event: event)
        case .openingSoon(let event):
            menuCategoryStackView.addArrangedSubview(HDivider())
            addMenuCategories(event: event)
        }
    }
    
    // MARK: - Set Up Views
    
    private func setupMenuCategoryStackView() {
        menuCategoryStackView.axis = .vertical
        menuCategoryStackView.alignment = .fill
        menuCategoryStackView.distribution = .equalSpacing
        menuCategoryStackView.spacing = 8
                
        addSubview(menuCategoryStackView)
        
        menuCategoryStackView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    // MARK: - Helpers
    
    private func addMenuCategories(event: Event) {
        event.menu?.categories.forEach { category in
            let menuCategoryView = EateryExpandableCardMenuCategoryView()
            menuCategoryView.configure(menuCategory: category)
            menuCategoryStackView.addArrangedSubview(menuCategoryView)
        }
    }
    
    func reset() {
        menuCategoryStackView.arrangedSubviews.forEach { subview in
            menuCategoryStackView.removeArrangedSubview(subview)
            guard let categorySubView = subview as? EateryExpandableCardMenuCategoryView else { return }
            categorySubView.reset()
        }
    }
    
}

