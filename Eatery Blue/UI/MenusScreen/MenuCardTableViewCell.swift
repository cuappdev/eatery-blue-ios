//
//  MenuCardTableViewCell.swift
//  Eatery Blue
//
//  Created by Antoinette Marie Torres on 9/26/23.
//

import EateryModel
import SnapKit
import UIKit

class MenuCardTableViewCell: UITableViewCell {

    // MARK: - Properties (view)

    private let containerView = UIView()
    private let expandableCardDetailView = EateryExpandableCardDetailView()
    private let expandableCardContentView = EateryExpandableCardContentView()
    private let stackView = UIStackView()
    
    // MARK: - Properties (data)

    static let reuse = "MenuCardCollectionViewCellReuseId"

    // MARK: - Constants

    private struct Constants {
        static let cellPadding: CGFloat = 12
    }
    
    // MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.backgroundColor = .Eatery.offWhite

        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = 8
        containerView.layer.shadowRadius = 6
        containerView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        containerView.layer.shadowColor = UIColor.Eatery.shadowLight.cgColor
        containerView.layer.shadowOpacity = 0.25

        setupStackView()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - configure
    
    func configure(expandedEatery: MenusViewController.ExpandedEatery, allEateries: [Eatery]) {
        expandableCardContentView.configure(expandedEatery: expandedEatery, allEateries: allEateries)

        if let selectedMealType = expandedEatery.selectedMealType,
           let selectedDay = expandedEatery.selectedDate  {
            expandableCardDetailView.configure(eatery: expandedEatery.eatery, selectedDay: selectedDay, selectedMealType: selectedMealType, allEateries: allEateries)
        }
        
        if expandedEatery.isExpanded {
            expandableCardContentView.toggleChevron(bool: true)
        } else {
            expandableCardContentView.toggleChevron(bool: false)
        }
        
        expandableCardDetailView.isHidden = !expandedEatery.isExpanded
    }
    
    // MARK: - Set Up Views
    
    private func setupStackView() {
        stackView.addArrangedSubview(expandableCardContentView)
        stackView.addArrangedSubview(expandableCardDetailView)
        
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 8
        containerView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(Constants.cellPadding)
            make.trailing.bottom.equalToSuperview().inset(Constants.cellPadding)
        }

        contentView.addSubview(containerView)

        containerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().inset(8)
        }


    }
    
    // MARK: - Helpers
    
    override func prepareForReuse() {
        expandableCardDetailView.reset()
        expandableCardContentView.reset()
    }
    
}
