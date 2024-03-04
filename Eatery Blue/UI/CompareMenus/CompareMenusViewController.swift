//
//  CompareMenusViewController.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi  on 3/2/24.
//

import EateryModel
import Foundation
import UIKit

class CompareMenusViewController: SheetViewController {

    let scrollView = UIScrollView()
    let eaterySelectionView = UIStackView()
    let compareNowButton = UIButton()
    let filterController = EateryFilterViewController()

    let toCompareWith: Eatery
    let eateries: [Eatery]

    var selectedEateries: [Eatery] = []

    init(toCompareWith: Eatery, eateries: [Eatery]) {
        self.toCompareWith = toCompareWith
        self.eateries = eateries.filter { eatery in eatery != toCompareWith }
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
        filterController.didMove(toParent: self)
        filterController.view.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }

    private func setUpScrollView() {
        scrollView.showsVerticalScrollIndicator = false
    }

    private func setUpSelectionView() {
        eaterySelectionView.axis = .vertical
        eaterySelectionView.alignment = .fill
        eaterySelectionView.distribution = .equalSpacing
        eaterySelectionView.spacing = 12

        let starterCell = CompareMenusEaterySelectionCell(eatery: toCompareWith)
        starterCell.toggle()
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

        for eatery in eateries {
            if eatery == toCompareWith { continue }

            let cell = CompareMenusEaterySelectionCell(eatery: eatery)

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
//        compareNowButton./*setTitleColor*/(UIColor(named: "EateryBlue"), for: .normal)
        compareNowButton.isEnabled = false
        compareNowButton.layer.cornerRadius = 25
    }

    private func setUpConstraints() {
        scrollView.snp.makeConstraints { make in
            make.height.equalTo(512)
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

    private func checkForEnoughSelected() {
        if selectedEateries.count >= 2 {
            compareNowButton.isEnabled = true
            compareNowButton.backgroundColor = UIColor(named: "EateryBlue")
        } else {
            compareNowButton.isEnabled = false
            compareNowButton.backgroundColor = UIColor(named: "Gray00")
            compareNowButton.setTitle("Select at least \(2 - selectedEateries.count) more", for: .disabled)
        }
    }
}

