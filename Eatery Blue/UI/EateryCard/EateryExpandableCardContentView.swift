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
    private let eateryDetailsButton = PillButtonView()
    private var expandedEatery: ExpandedEatery?

    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupEateryStackView()
        setupEateryNameLabel()
        setupEateryStatusLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - configure
    
    func configure(expandedEatery: ExpandedEatery) {
        self.expandedEatery = expandedEatery
        eateryNameLabel.text = expandedEatery.eatery.name

        let selectedEvents = expandedEatery.eatery.events.filter { $0.canonicalDay == expandedEatery.selectedDate }
        let selectedMealType = expandedEatery.selectedMealType
        var event: Event?

        // Ignoring Late Lunch
        if selectedMealType == "Breakfast" {
            event = selectedEvents.first { $0.description == "Brunch" || $0.description == "Breakfast" }
        } else if selectedMealType == "Lunch" {
            event = selectedEvents.first { $0.description == "Brunch" || $0.description == "Lunch"}
        } else if selectedMealType == "Dinner" {
            event = selectedEvents.first { $0.description == "Dinner" }
        } else if selectedMealType == "Late Dinner" {
            event = selectedEvents.first { $0.description == "Late Night" }
        }

        if let event {
            eateryStatusLabel.text = EateryFormatter.default.formatEventTime(event)
            if event.canonicalDay == Day() {
                if expandedEatery.eatery.status.isOpen && !(event.menu?.categories.isEmpty ?? false) {
                    setupChevronArrow()
                }
            } else {
                setupChevronArrow()
            }
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
            make.width.equalTo(snp.width).multipliedBy(0.50)
        }
    }

    private func setupChevronArrow() {
        chevronArrow.image = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate)
        chevronArrow.tintColor = .black
        chevronArrow.contentMode = .scaleAspectFit
        
        addSubview(chevronArrow)
        
        chevronArrow.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
    }
    
    private func setupEateryNameLabel() {
        eateryNameLabel.textColor = UIColor.Eatery.black
        eateryNameLabel.font = UIFont.preferredFont(for: .title3, weight: .semibold)

        eateryStackView.addArrangedSubview(eateryNameLabel)
    }
    
    private func setupEateryStatusLabel() {
        eateryStatusLabel.textColor = UIColor.Eatery.gray03
        eateryStatusLabel.font = UIFont.preferredFont(for: .footnote, weight: .medium)

        eateryStackView.addArrangedSubview(eateryStatusLabel)
    }
    
    private func setupEateryDetailsButton() {
        eateryDetailsButton.backgroundColor = UIColor.Eatery.gray00
        eateryDetailsButton.imageView.image = UIImage(named: "EateryDetails")?.withRenderingMode(.alwaysTemplate)
        eateryDetailsButton.imageView.tintColor = UIColor.Eatery.gray05
        eateryDetailsButton.titleLabel.textColor = UIColor.Eatery.black
        eateryDetailsButton.titleLabel.font = .preferredFont(for: .subheadline, weight: .semibold)
        eateryDetailsButton.titleLabel.text = "Eatery Details"
        eateryDetailsButton.isUserInteractionEnabled = true
        eateryDetailsButton.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(didTapEateryDetails(_:))
        ))
        
        addSubview(eateryDetailsButton)
        
        eateryDetailsButton.snp.makeConstraints { make in
            make.width.equalTo(snp.width).multipliedBy(0.43)
            make.height.equalTo(42)
            make.trailing.centerY.equalToSuperview()
        }
    }
    
    // MARK: - Tap recognizer
    
    @objc private func didTapEateryDetails(_ sender: UITapGestureRecognizer) {
        if let navigationController = findNavigationController() {
            let eateryVC = EateryModelController()
            if let eatery = expandedEatery?.eatery {
                eateryVC.setUp(eatery: eatery)
                eateryVC.setUpMenu(eatery: eatery)
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
    
    func reset() {
        eateryDetailsButton.removeFromSuperview()
        chevronArrow.removeFromSuperview()
    }
    
    func toggleChevron(bool: Bool) {
        if bool {
            chevronArrow.image = UIImage(systemName: "chevron.up")?.withRenderingMode(.alwaysTemplate)
        }
        else {
            chevronArrow.image = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate)
        }
    }

}
