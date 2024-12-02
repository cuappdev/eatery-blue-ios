//
//  EateryListView.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 10/26/24.
//

import EateryModel
import UIKit

class EateryListView: UIView {

    // MARK: - Properties (View)

    private let tableView = UITableView()

    // MARK: - Properties (Data)

    var allEateries: [Eatery] = [] {
        didSet {
            updateEateriesFromState()
        }
    }
    var listEateries: [Eatery] = [] {
        didSet {
            updateEateriesFromState()
        }
    }
    var navigationController: UINavigationController?

    private var filter = EateryFilter()
    private let filterController = EateryFilterViewController()
    private var previousEateries: [Eatery] = []
    private var shownEateries: [Eatery] = []

    // MARK: - Init

    init() {
        super.init(frame: .zero )
        setUpSelf()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        backgroundColor = .white

        addSubview(tableView)
        setUpTableView()

        setUpEateriesFilterViewController()

        setUpConstraints()
    }

    private func setUpTableView() {
        tableView.showsVerticalScrollIndicator = false
        tableView.alwaysBounceVertical = true
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func setUpEateriesFilterViewController() {
        filterController.delegate = self
    }

    private func setUpConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func reloadTableViewData(newEateries: [Eatery]) {
        var rowsToInsert: [IndexPath] = []
        var rowsToDelete: [IndexPath] = []
        var rowsToReload: [IndexPath] = []

        for i in 0..<max(newEateries.count, previousEateries.count) {
            let path = IndexPath(row: i, section: 1)
            if i >= newEateries.count {
                i > 0 ? rowsToDelete.append(path) : rowsToReload.append(path)
            }
            else if i >= previousEateries.count {
                i > 0 ? rowsToInsert.append(path) : rowsToReload.append(path)
            }
            else if previousEateries[i] != newEateries[i] {
                rowsToReload.append(path)
            }
        }

        tableView.beginUpdates()
        shownEateries = newEateries

        tableView.performBatchUpdates {
            tableView.deleteRows(at: rowsToDelete, with: .fade)
            tableView.insertRows(at: rowsToInsert, with: .fade)
            tableView.reloadRows(at: rowsToReload, with: .fade)
        }

        tableView.endUpdates()
    }

    private func updateEateriesFromState() {
        previousEateries = shownEateries

        var updatedEateries: [Eatery] = []

        if filter.isEnabled {
            let predicate = filter.predicate(userLocation: LocationManager.shared.userLocation, departureDate: Date())
            let coreDataStack = AppDelegate.shared.coreDataStack

            var filteredEateries: [Eatery] = []
            for eatery in listEateries {
                if predicate.isSatisfied(by: eatery, metadata: coreDataStack.metadata(eateryId: eatery.id)) {
                    filteredEateries.append(eatery)
                }
            }

            updatedEateries = filteredEateries
        } else {
            updatedEateries = listEateries
        }

        reloadTableViewData(newEateries: updatedEateries)
    }

}

// MARK: - Table View Data Source

extension EateryListView: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let shownEateriesCount = max(shownEateries.count, 1)
        return section == 1 ? shownEateriesCount: 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let container = ContainerView(content: filterController.view)
            container.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 8, right: 16)

            let cell = ClearTableViewCell(content: container)
            cell.selectionStyle = .none
            return cell
        }

        if shownEateries.isEmpty {
            let label = UILabel()
            label.text = "No eateries found..."
            label.font = .preferredFont(for: .title2, weight: .semibold)
            let container = ContainerView(content: label)
            container.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 8, right: 16)

            let cell = ClearTableViewCell(content: container)
            cell.selectionStyle = .none
            return cell
        }

        let eatery = shownEateries[indexPath.row]
        let largeCardContent = EateryLargeCardContentView()

        largeCardContent.configure(eatery: eatery)

        let cardView = EateryCardVisualEffectView(content: largeCardContent)
        cardView.layoutMargins = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)

        let cell = ClearTableViewCell(content: cardView)
        cell.selectionStyle = .none
        return cell
    }

}

// MARK: - Table View Delegate

extension EateryListView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { return }

        let pageVC = EateryPageViewController(eateries: shownEateries, index: indexPath.row)
        navigationController?.hero.isEnabled = true
        navigationController?.heroNavigationAnimationType = .fade
        navigationController?.pushViewController(pageVC, animated: true)
    }

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        UIView.animate(withDuration: 0.15, delay: 0, options: .beginFromCurrentState) {
            cell?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        UIView.animate(withDuration: 0.15, delay: 0, options: .beginFromCurrentState) {
            cell?.transform = .identity
        }
    }

}

// MARK: - Filter View Controller Delegate

extension EateryListView: EateryFilterViewControllerDelegate {

    func eateryFilterViewController(_ viewController: EateryFilterViewController, filterDidChange filter: EateryFilter) {
        self.filter = filter
        updateEateriesFromState()
    }

}
