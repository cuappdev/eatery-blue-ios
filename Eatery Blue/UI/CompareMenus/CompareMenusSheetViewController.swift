//
//  CompareMenusViewController.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi  on 3/2/24.
//

import EateryModel
import UIKit

class CompareMenusSheetViewController: SheetViewController {

    // MARK: - Properties (data)

    private let allEateries: [Eatery]
    private var filter = EateryFilter()
    private var selectedEateries: [Eatery] = []
    private var shownEateries: [Eatery]

    // MARK: - Properties (view)

    private let backgroundView = UILabel()
    private let compareNowButton = UIButton()
    private let filterController = CompareMenusFilterViewController()
    private let parentNavigationController: UINavigationController?
    private var selectionTableView = UITableView()

    // MARK: - Init

    init(parentNavigationController: UINavigationController?, allEateries: [Eatery], selectedEateries: [Eatery] = [], selectedOn: Bool = false) {
        self.parentNavigationController = parentNavigationController
        self.selectedEateries = selectedEateries
        self.allEateries = allEateries
        self.shownEateries = allEateries

        super.init(nibName: nil, bundle: nil)

        setUpSelf()
        if selectedOn {
            filterController.tapSelected()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setUpSelf() {
        addHeader(title: "Compare Menus")

        addChild(filterController)
        stackView.addArrangedSubview(filterController.view)
        setUpFilterController()

        stackView.addArrangedSubview(selectionTableView)
        setUpSelectionView()

        stackView.addArrangedSubview(compareNowButton)
        setUpCompareButton()

        setUpConstraints()
        updateSelected()
    }

    private func setUpFilterController() {
        filterController.viewController = self
        filterController.didMove(toParent: self)
        filterController.delegate = self
    }

    private func setUpSelectionView() {
        selectionTableView.register(CompareMenusEaterySelectionCell.self, forCellReuseIdentifier: CompareMenusEaterySelectionCell.reuse)
        selectionTableView.dataSource = self
        selectionTableView.delegate = self
        selectionTableView.allowsSelectionDuringEditing = true
        selectionTableView.showsVerticalScrollIndicator = false

        backgroundView.text = "No eateries to show..."
        backgroundView.font = .systemFont(ofSize: 20, weight: .semibold)
        selectionTableView.backgroundView = backgroundView
        selectionTableView.backgroundView?.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
        }
    }

    private func setUpCompareButton() {
        compareNowButton.setTitle("Select at least 1 more", for: .disabled)
        compareNowButton.setTitle("Compare now", for: .normal)
        compareNowButton.setTitleColor(UIColor(named: "Gray03"), for: .disabled)
        compareNowButton.setTitleColor(.white, for: .normal)
        compareNowButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)

        compareNowButton.backgroundColor = UIColor(named: "Gray00")
        compareNowButton.isEnabled = false
        compareNowButton.layer.cornerRadius = 25

        compareNowButton.addTarget(self, action: #selector(buttonTouchUpInside), for: .touchUpInside)
        compareNowButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        compareNowButton.addTarget(self, action: #selector(buttonTouchUpOutside), for: .touchUpOutside)
    }

    private func setUpConstraints() {
        selectionTableView.snp.makeConstraints { make in
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

        let viewController = CompareMenusViewController(allEateries: allEateries, comparedEateries: selectedEateries)
        parentNavigationController?.pushViewController(viewController, animated: true)
        self.dismiss(animated: true)
        let eateryNames = selectedEateries.map { $0.name }
        AppDevAnalytics.shared.logFirebase(CompareMenusStartComparingPayload(eateries: eateryNames))
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
            compareNowButton.setTitle("Select at least 2", for: .disabled)
        }
    }

    private func updateEateriesFromState() {
        if filter.isEnabled {
            let predicate = filter.predicate(userLocation: LocationManager.shared.userLocation, departureDate: Date())
            let coreDataStack = AppDelegate.shared.coreDataStack

            var filteredEateries: [Eatery] = []
            for eatery in allEateries {
                if predicate.isSatisfied(by: eatery, metadata: coreDataStack.metadata(eateryId: eatery.id)) {
                    filteredEateries.append(eatery)
                }
            }

            shownEateries = filteredEateries

            if filter.selected {
                shownEateries = selectedEateries
            }
        } else {
            shownEateries = allEateries
        }

        selectionTableView.reloadData()
    }

    private func enableDragging() {
        selectionTableView.isEditing = true
        if selectedEateries.count != 0 {
            backgroundView.text = ""
        }
    }

    private func disableDragging() {
        selectionTableView.isEditing = false
        backgroundView.text = "No eateries to show..."
    }

}

extension CompareMenusSheetViewController: EateryFilterViewControllerDelegate {

    func eateryFilterViewController(_ viewController: EateryFilterViewController, filterDidChange filter: EateryFilter) {
        self.filter = filter
        filter.selected ? enableDragging() : disableDragging()

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
        let filled = selectedEateries.contains { $0.id == cellEatery.id }
        let draggable = tableView.isEditing

        cell.configure(eatery: shownEateries[indexPath.row], filled: filled, draggable: draggable)
        return cell
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let moved = shownEateries[sourceIndexPath.row]
        if !selectedEateries.contains(moved) { return }

        shownEateries.remove(at: sourceIndexPath.row)
        shownEateries.insert(moved, at: destinationIndexPath.row)

        selectedEateries = shownEateries.filter { selectedEateries.contains($0) }

        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

}

extension CompareMenusSheetViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedEatery = shownEateries[indexPath.row]
        if selectedEateries.contains(where: { $0.id == selectedEatery.id }) {
            selectedEateries.removeAll { $0.id == selectedEatery.id }
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
