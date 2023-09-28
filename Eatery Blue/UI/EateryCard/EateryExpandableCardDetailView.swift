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
    private let viewEateryDetails = PillButtonView()
    private var eatery: Eatery?
    
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
        self.eatery = eatery
        
        switch eatery.status {
        case .closed:
            break
        case .closingSoon(let event):
            menuCategoryStackView.addArrangedSubview(HDivider())
            addMenuCategories(event: event)
            setupViewEateryDetailsButton()
        case .open(let event):
            menuCategoryStackView.addArrangedSubview(HDivider())
            addMenuCategories(event: event)
            setupViewEateryDetailsButton()
        case .openingSoon(let event):
            menuCategoryStackView.addArrangedSubview(HDivider())
            addMenuCategories(event: event)
            setupViewEateryDetailsButton()
            
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
            make.top.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupViewEateryDetailsButton() {
        viewEateryDetails.backgroundColor = UIColor.Eatery.gray00
        viewEateryDetails.imageView.image = UIImage(named: "EateryDetails")?.withRenderingMode(.alwaysTemplate)
        viewEateryDetails.imageView.tintColor = UIColor.Eatery.gray05
        viewEateryDetails.titleLabel.textColor = UIColor.Eatery.black
        viewEateryDetails.titleLabel.text = "View Eatery Details"
        viewEateryDetails.isUserInteractionEnabled = true
        viewEateryDetails.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(didTapEateryDetails(_:))
        ))
        
        addSubview(viewEateryDetails)
        
        viewEateryDetails.snp.makeConstraints { make in
            make.height.equalTo(36)
            make.width.equalTo(324)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalTo(menuCategoryStackView.snp.bottom).offset(8)
            make.bottom.equalToSuperview().inset(8)
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
    
    // MARK: - Tap recognizer
    
    @objc private func didTapEateryDetails(_ sender: UITapGestureRecognizer) {
        if let navigationController = findNavigationController() {
            let eateryVC = EateryModelController()
            if let eatery {
                eateryVC.setUp(eatery: eatery)
            }
            navigationController.pushViewController(eateryVC, animated: true)
        }
    }
    
    private func findNavigationController() -> UINavigationController? {
        var responder: UIResponder? = self
        while let currentResponder = responder {
            if let navigationController = currentResponder as? UINavigationController {
                return navigationController
            }
            responder = currentResponder.next
        }
        return nil
    }
}

