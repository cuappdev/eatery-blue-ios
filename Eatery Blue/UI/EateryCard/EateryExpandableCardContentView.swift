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
    private let eateryDetailsButton = UIButton()
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupEateryStackView()
        setupEateryNameLabel()
        setupEateryStatusLabel()
        setupChevronArrow()
        setupEateryDetailsButton()
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
            eateryStatusLabel.textColor = UIColor.Eatery.red
            eateryDetailsButton.isHidden.toggle()
        case .closingSoon(_):
            eateryStatusLabel.text = "Closing Soon"
            eateryStatusLabel.textColor = UIColor.Eatery.orange
            chevronArrow.isHidden.toggle()
        case .open(_):
            eateryStatusLabel.text = "Open"
            eateryStatusLabel.textColor = UIColor.Eatery.green
            chevronArrow.isHidden.toggle()
        case .openingSoon(_):
            eateryStatusLabel.text = "Opening Soon"
            eateryStatusLabel.textColor = UIColor.Eatery.green
            chevronArrow.isHidden.toggle()

        }
    }
    
    // MARK: - Set Up Views
    
    private func setupEateryStackView() {
        eateryStackView.axis = .vertical
        eateryStackView.distribution = .equalSpacing
        eateryStackView.alignment = .fill
        eateryStackView.spacing = 4
        
        addSubview(eateryStackView)
        
        eateryStackView.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width - 84)
        }
    }

    private func setupChevronArrow() {
        chevronArrow.image = UIImage(named: "ExpandDown")
        chevronArrow.contentMode = .scaleAspectFit
        chevronArrow.isHidden = true
        
        if !chevronArrow.isHidden {
            addSubview(chevronArrow)
        }
        
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
    
    private func setupEateryDetailsButton() {
        eateryDetailsButton.setTitle("Eatery Details", for: .normal)
        eateryDetailsButton.titleLabel?.textColor = UIColor.Eatery.gray06
        eateryDetailsButton.setImage(UIImage(named: "EateryDetails"), for: .normal)
        eateryDetailsButton.isHidden = true
        
        if !eateryDetailsButton.isHidden {
            eateryStackView.addArrangedSubview(eateryDetailsButton)
        }
        
        eateryDetailsButton.snp.makeConstraints { make in
            make.width.equalTo(140)
            make.top.bottom.trailing.centerY.equalToSuperview()
        }
    }
}
