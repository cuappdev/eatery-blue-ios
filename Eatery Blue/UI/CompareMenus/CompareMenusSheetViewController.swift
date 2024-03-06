//
//  CompareMenusViewController.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi  on 3/2/24.
//

import EateryModel
import Foundation
import UIKit

class CompareMenusSheetViewController: SheetViewController {

    let scrollView = UIScrollView()
    var eaterySelectionView = UIStackView()
    let compareNowButton = UIButton()
    var filterController = EateryFilterViewController()
    var filter = EateryFilter()

    let navController: UINavigationController?
    let toCompareWith: Eatery
    let eateries: [Eatery]
    var shownEateries: [Eatery]

    var selectedEateries: [Eatery] = []

    init(navController: UINavigationController?, toCompareWith: Eatery, eateries: [Eatery]) {
        self.navController = navController
        self.toCompareWith = toCompareWith
        self.eateries = eateries.filter { $0 != toCompareWith }
        self.shownEateries = eateries.filter { $0 != toCompareWith }
        super.init(nibName: nil, bundle: nil)
        selectedEateries.append(toCompareWith)
        setUpSelf()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpSelf() {
        addHeader(title: "Compare Menus")

        addChild(filterController)
        stackView.addArrangedSubview(filterController.view)
        setUpFilterController()

        stackView.addArrangedSubview(scrollView)
        setUpScrollView()

        scrollView.addSubview(eaterySelectionView)
        setUpSelectionView()

        stackView.addArrangedSubview(compareNowButton)
        setUpCompareButton()

        setUpConstraints()
    }

    private func setUpFilterController() {
        filterController.setConnectedViewController(viewController: self)
        filterController.didMove(toParent: self)
        filterController.delegate = self
    }

    private func setUpScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
    }

    private func setUpSelectionView() {
        for view in eaterySelectionView.arrangedSubviews {
            view.removeFromSuperview()
            eaterySelectionView.removeArrangedSubview(view)
        }
        eaterySelectionView.axis = .vertical
        eaterySelectionView.alignment = .fill
        eaterySelectionView.distribution = .equalSpacing
        eaterySelectionView.spacing = 12

        let starterCell = CompareMenusEaterySelectionCell(eatery: toCompareWith)
        if selectedEateries.contains(toCompareWith) {
            starterCell.toggle()
        }

        starterCell.tap { [weak self] _ in
            guard let self else { return }
            starterCell.toggle()
            if !starterCell.filled {
                selectedEateries.removeAll { eatery in
                    eatery == starterCell.eatery
                }
            } else {
                selectedEateries.append(starterCell.eatery)
            }
            checkForEnoughSelected()
        }
        eaterySelectionView.addArrangedSubview(starterCell)

        for eatery in shownEateries {
            if eatery == toCompareWith { continue }

            let cell = CompareMenusEaterySelectionCell(eatery: eatery)

            if selectedEateries.contains(eatery) {
                cell.toggle()
            }

            cell.tap { [weak self] _ in
                guard let self else { return }
                cell.toggle()
                if !cell.filled {
                    selectedEateries.removeAll { eatery in
                        eatery == cell.eatery
                    }
                } else {
                    selectedEateries.append(cell.eatery)
                }
                checkForEnoughSelected()
            }

            eaterySelectionView.addArrangedSubview(cell)
        }
    }

    private func setUpCompareButton() {
        compareNowButton.setTitle("Select at least 1 more", for: .disabled)
        compareNowButton.setTitle("Compare now", for: .normal)
        compareNowButton.setTitleColor(UIColor(named: "Gray03"), for: .disabled)
        compareNowButton.setTitleColor(.white, for: .normal)

        compareNowButton.backgroundColor = UIColor(named: "Gray00")
        compareNowButton.isEnabled = false
        compareNowButton.layer.cornerRadius = 25

        compareNowButton.addTarget(self, action: #selector(buttonTouchUpInside), for: .touchUpInside)
        compareNowButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        compareNowButton.addTarget(self, action: #selector(buttonTouchUpOutside), for: .touchUpOutside)    }

    private func setUpConstraints() {
        scrollView.snp.makeConstraints { make in
            make.height.equalTo(360).dividedBy(3).multipliedBy(2)
        }

        eaterySelectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        compareNowButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.width.equalToSuperview()
        }
    }

    @objc private func buttonTouchUpInside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.15, delay: 0, options: .beginFromCurrentState) {
            sender.transform = .identity
        }
        let viewController = CompareMenusViewController(eateries: selectedEateries, index: 0)
        navController?.pushViewController(viewController, animated: true)
        self.dismiss(animated: true)
    }

    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.15, delay: 0, options: .beginFromCurrentState) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    @objc private func buttonTouchUpOutside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.15, delay: 0, options: .beginFromCurrentState) {
            sender.transform = .identity
        }
    }

    private func checkForEnoughSelected() {
        if selectedEateries.count >= 2 {
            compareNowButton.isEnabled = true
            compareNowButton.backgroundColor = UIColor(named: "EateryBlue")
            compareNowButton.setTitle("Compare \(selectedEateries.count) now", for: .normal)
        } else {
            compareNowButton.isEnabled = false
            compareNowButton.backgroundColor = UIColor(named: "Gray00")
            compareNowButton.setTitle("Select at least \(2 - selectedEateries.count) more", for: .disabled)
        }
    }

    func updateEateriesFromState() {
        if filter.isEnabled {
            let predicate = filter.predicate(userLocation: LocationManager.shared.userLocation, departureDate: Date())
            let coreDataStack = AppDelegate.shared.coreDataStack

            var filteredEateries: [Eatery] = []
            for eatery in eateries {
                if predicate.isSatisfied(by: eatery, metadata: coreDataStack.metadata(eateryId: eatery.id)) {
                    filteredEateries.append(eatery)
                }
            }
            shownEateries = filteredEateries

        } else {
            shownEateries = eateries
        }
        setUpSelectionView()
    }

    func addSpacer(height: CGFloat, color: UIColor? = UIColor.Eatery.gray00) {
        let spacer = UIView()
        spacer.backgroundColor = color
        stackView.addArrangedSubview(spacer)
        spacer.snp.makeConstraints { make in
            make.height.equalTo(height)
        }
    }

}

extension CompareMenusSheetViewController: EateryFilterViewControllerDelegate {
    func eateryFilterViewController(_ viewController: EateryFilterViewController, filterDidChange filter: EateryFilter) {
        self.filter = filter
        updateEateriesFromState()
    }
}
