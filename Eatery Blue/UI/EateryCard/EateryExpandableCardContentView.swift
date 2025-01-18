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
    private var expandedEatery: ExpandedEatery?
    private var allEateries: [Eatery] = []

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
    
    func configure(expandedEatery: ExpandedEatery, allEateries: [Eatery]) {
        self.expandedEatery = expandedEatery
        self.allEateries = allEateries
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
            if event.canonicalDay == Day() {
                eateryStatusLabel.attributedText = EateryFormatter.default.formatStatusSimple(expandedEatery.eatery.status, followedBy: EateryFormatter.default.formatEventTime(event))
            } else {
                eateryStatusLabel.text = EateryFormatter.default.formatEventTime(event)
            }

            if event.endDate > Date() {
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
            make.trailing.equalToSuperview().inset(16)
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
    
    // MARK: - Tap recognizer
    
    @objc private func didTapEateryDetails(_ sender: UITapGestureRecognizer) {
        if let navigationController = findNavigationController() {
            if let eatery = expandedEatery?.eatery {
                let eateryVC = EateryModelController()
                eateryVC.setUp(eatery: eatery, isTracking: true)
                eateryVC.setUpMenu(eatery: eatery)
                navigationController.pushViewController(eateryVC, animated: true)
            }
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
