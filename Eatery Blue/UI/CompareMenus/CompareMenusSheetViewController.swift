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

    var eaterySelectionView = UITableView()
    let compareNowButton = UIButton()
    let backgroundView = UILabel()
    var filterController = CompareMenusFilterViewController()

    var filter = EateryFilter()

    let navController: UINavigationController?
    let toCompareWith: Eatery?
    let eateries: [Eatery]
    var shownEateries: [Eatery]

    var selectedEateries: [Eatery] = []

    init(navController: UINavigationController?, toCompareWith: Eatery?, eateries: [Eatery]) {
        self.navController = navController
        self.toCompareWith = toCompareWith
        self.eateries = eateries.filter { $0 != toCompareWith }
        self.shownEateries = eateries.filter { $0 != toCompareWith }
        super.init(nibName: nil, bundle: nil)

        if let toCompareWith {
            selectedEateries.append(toCompareWith)
        }
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

        stackView.addArrangedSubview(eaterySelectionView)
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

    private func setUpSelectionView() {
        eaterySelectionView.register(CompareMenusEaterySelectionCell.self, forCellReuseIdentifier: CompareMenusEaterySelectionCell.reuse)
        eaterySelectionView.dataSource = self
        eaterySelectionView.delegate = self

        backgroundView.text = "No eateries to show..."
        backgroundView.font = .systemFont(ofSize: 20, weight: .semibold)
        eaterySelectionView.backgroundView = backgroundView
        eaterySelectionView.backgroundView?.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
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
        compareNowButton.addTarget(self, action: #selector(buttonTouchUpOutside), for: .touchUpOutside)
    }

    private func setUpConstraints() {
        eaterySelectionView.snp.makeConstraints { make in
            make.height.equalTo(360)
            make.width.equalTo(stackView.snp.width)
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

    private func updateSelected() {
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

            if filter.selected {
                shownEateries = selectedEateries
            }
        } else {
            shownEateries = eateries
        }
        eaterySelectionView.reloadData()
    }

    private func enableDragging() {
        eaterySelectionView.isEditing = true
        if selectedEateries.count != 0 {
            backgroundView.text = ""
        }
    }

    private func disableDragging() {
        eaterySelectionView.isEditing = false
        backgroundView.text = "No eateries to show..."
    }
}

extension CompareMenusSheetViewController: EateryFilterViewControllerDelegate {
    func eateryFilterViewController(_ viewController: EateryFilterViewController, filterDidChange filter: EateryFilter) {
        self.filter = filter
        if filter.selected {
            enableDragging()
        } else {
            disableDragging()
        }
        updateEateriesFromState()
    }
}

extension CompareMenusSheetViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shownEateries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CompareMenusEaterySelectionCell.reuse, for: indexPath) as? CompareMenusEaterySelectionCell else { return UITableViewCell() }
        let cellEatery = shownEateries[indexPath.row]
        let filled = selectedEateries.contains(cellEatery)
        let draggable = tableView.isEditing
        cell.configure(eatery: shownEateries[indexPath.row], filled: filled, draggable: draggable)
        cell.selectionStyle = .none
        let cellBackground = UIView()
        cellBackground.backgroundColor = .white
        cell.backgroundView = cellBackground
        cellBackground.snp.makeConstraints { make in
            make.edges.equalTo(cell.snp.edges)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let moved = shownEateries[sourceIndexPath.row]
        selectedEateries.remove(at: sourceIndexPath.row)
        selectedEateries.insert(moved, at: destinationIndexPath.row)
        shownEateries.remove(at: sourceIndexPath.row)
        shownEateries.insert(moved, at: destinationIndexPath.row)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

extension CompareMenusSheetViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedEatery = shownEateries[indexPath.row]
        if selectedEateries.contains(selectedEatery) {
            selectedEateries.removeAll { eatery in
                eatery == selectedEatery
            }
        } else {
            selectedEateries.append(selectedEatery)
        }
        updateSelected()
        tableView.reloadRows(at: [indexPath], with: .none)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
