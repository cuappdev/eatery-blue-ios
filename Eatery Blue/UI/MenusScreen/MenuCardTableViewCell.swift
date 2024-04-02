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
    
    private let expandableCardDetailView = EateryExpandableCardDetailView()
    private let expandableCardContentView = EateryExpandableCardContentView()
    private let stackView = UIStackView()
    
    // MARK: - Constants
    
    private struct Constants {
        static let cellPadding: CGFloat = 12
    }
    
    // MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor.white
        contentView.layer.cornerRadius = 8
        contentView.layer.shadowRadius = 6
        contentView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        contentView.layer.shadowColor = UIColor.Eatery.shadowLight.cgColor
        contentView.layer.shadowOpacity = 0.25
        selectionStyle = .none
        
        setupStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - configure
    
    func configure(expandedEatery: ExpandedEatery, allEateries: [Eatery]) {
        expandableCardContentView.configure(expandedEatery: expandedEatery, allEateries: allEateries)

        if let selectedMealType = expandedEatery.selectedMealType,
           let selectedDay = expandedEatery.selectedDate  {
            expandableCardDetailView.configure(eatery: expandedEatery.eatery, selectedDay: selectedDay, selectedMealType: selectedMealType)
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
        
        contentView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(Constants.cellPadding)
            make.trailing.bottom.equalToSuperview().inset(Constants.cellPadding)
        }
    }
    
    // MARK: - Helpers
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: Constants.cellPadding, bottom: 0, right: Constants.cellPadding))
    }
    
    override func prepareForReuse() {
        expandableCardDetailView.reset()
        expandableCardContentView.reset()
    }
    
}
