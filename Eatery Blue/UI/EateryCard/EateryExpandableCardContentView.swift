//
//  EateryExpandableCardContentView.swift
//  Eatery Blue
//
//  Created by Antoinette Marie Torres on 9/23/23.
//

import EateryModel
import SnapKit
import UIKit

class EateryExpandableCardContentView: UIView {
    
    // MARK: - Properties (view)
    
    private let chevronArrow = UIImageView()
    private let eateryNameLabel = UILabel()
    private let eateryStackView = UIStackView()
    private let eateryStatusLabel = UILabel()
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupEateryStackView()
        setupEateryNameLabel()
        setupEateryStatusLabel()
        setupChevronArrow()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - configure
    
    func configure(eatery: Eatery) {
        eateryNameLabel.text = eatery.name
        
        // TODO: Configure below
        switch eatery.status {
        case .closed:
            eateryStatusLabel.text = "Closed"
        case .closingSoon(_):
            eateryStatusLabel.text = "Closing Soon"
        case .open(_):
            eateryStatusLabel.text = "Open"
        case .openingSoon(_):
            eateryStatusLabel.text = "Opening Soon"
        }
    }
    
    // MARK: - Set Up Views
    
    private func setupEateryStackView() {
        eateryStackView.axis = .vertical
        eateryStackView.distribution = .fill
        eateryStackView.alignment = .fill
        
        addSubview(eateryStackView)
        
        eateryStackView.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width - 84)
        }
    }

    private func setupChevronArrow() {
        chevronArrow.image = UIImage(named: "ExpandDown")
        chevronArrow.contentMode = .scaleAspectFit
        
        addSubview(chevronArrow)
        
        chevronArrow.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
    }
    
    private func setupEateryNameLabel() {
        eateryNameLabel.textColor = UIColor.Eatery.black
        eateryNameLabel.font = UIFont.preferredFont(for: .title3, weight: .semibold)

        eateryStackView.addArrangedSubview(eateryNameLabel)
    }
    
    private func setupEateryStatusLabel() {
        eateryStatusLabel.textColor = UIColor.Eatery.black
        eateryStatusLabel.font = UIFont.preferredFont(for: .footnote, weight: .medium)

        eateryStackView.addArrangedSubview(eateryStatusLabel)
    }
    
}
