//
//  EateryListView.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 10/26/24.
//

import EateryModel
import UIKit

class EateryListView: UIView {
    // MARK: - Properties (view)

    private let tableView = UITableView()

    // MARK: - Properties (data)

    /// Eateries to display in the list view when no filter is applied
    var eateries: [Eatery] = [] {
        didSet {
            updateEateriesFromState(animated: !oldValue.isEmpty)
        }
    }

    /// The navigation controller that this view uses to pop on back button press
    var navigationController: UINavigationController?

    private var filter = EateryFilter()
    private let filterController = EateryFilterViewController()
    private var shownEateries: [Eatery] = []

    private lazy var dataSource = makeDataSource()

    // MARK: - Init

    init() {
        super.init(frame: .zero)
        setUpSelf()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        backgroundColor = .white

        addSubview(tableView)
        setUpTableView()

        setUpEateriesFilterViewController()

        setUpConstraints()
        applySnapshot(animated: true)
    }

    private func setUpTableView() {
        tableView.register(ClearTableViewCell.self, forCellReuseIdentifier: ClearTableViewCell.reuse)
        tableView.showsVerticalScrollIndicator = false
        tableView.alwaysBounceVertical = true
        tableView.separatorStyle = .none
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

    private func updateEateriesFromState(animated: Bool = true) {
        var updatedEateries: [Eatery] = []

        if filter.isEnabled {
            let predicate = filter.predicate(userLocation: LocationManager.shared.userLocation, departureDate: Date())
            let coreDataStack = AppDelegate.shared.coreDataStack

            let filteredEateries = eateries.filter { eatery in
                predicate.isSatisfied(by: eatery, metadata: coreDataStack.metadata(eateryId: eatery.id))
            }

            updatedEateries = filteredEateries
        } else {
            updatedEateries = eateries
        }

        shownEateries = updatedEateries
        applySnapshot(animated: animated)
    }

    // MARK: - Table View Data Source

    /// Creates and returns the table view data source
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(tableView: tableView) { [weak self] tableview, indexPath, row in
            guard let self else { return UITableViewCell() }
            guard let cell = tableview.dequeueReusableCell(
                withIdentifier: ClearTableViewCell.reuse,
                for: indexPath
            ) as? ClearTableViewCell else { return UITableViewCell() }

            switch row {
            case let .eatery(eatery, bool):
                let largeCardContent = EateryLargeCardView()
                largeCardContent.configure(eatery: eatery, favorited: bool)
                let cardView = EateryCardVisualEffectView(content: largeCardContent)
                cardView.layoutMargins = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
                cell.configure(content: cardView)
            case .filter:
                let container = ContainerView(content: self.filterController.view)
                container.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 8, right: 16)
                cell.configure(content: container)
            case let .label(text):
                let label = UILabel()
                label.text = text
                label.font = .preferredFont(for: .title2, weight: .semibold)
                let container = ContainerView(content: label)
                container.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 8, right: 16)
                cell.configure(content: container)
            }

            cell.selectionStyle = .none
            return cell
        }

        return dataSource
    }

    /// Updates the table view data source, and animates if desired
    private func applySnapshot(animated: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems([.filter])

        let coreDataStack = AppDelegate.shared.coreDataStack

        if shownEateries.isEmpty {
            snapshot.appendItems([.label("No eateries found")])
        } else {
            for eatery in shownEateries {
                let favorited = coreDataStack.metadata(eateryId: eatery.id).isFavorite
                snapshot.appendItems([.eatery(eatery: eatery, favorited: favorited)], toSection: .main)
            }
        }

        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}

// MARK: - Extensions

extension EateryListView: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = dataSource.itemIdentifier(for: indexPath) {
            switch cell {
            case let .eatery(eatery, _):
                let idx = shownEateries.firstIndex(of: eatery) ?? 0
                let pageVC = EateryPageViewController(eateries: shownEateries, index: idx)
                navigationController?.hero.isEnabled = true
                navigationController?.heroNavigationAnimationType = .fade
                navigationController?.pushViewController(pageVC, animated: true)
            default:
                break
            }
        }
    }

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView
            .dequeueReusableCell(withIdentifier: ClearTableViewCell.reuse, for: indexPath) as? ClearTableViewCell
        else { return }

        UIView.animate(withDuration: 0.15, delay: 0, options: .beginFromCurrentState) {
            cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView
            .dequeueReusableCell(withIdentifier: ClearTableViewCell.reuse, for: indexPath) as? ClearTableViewCell
        else { return }

        UIView.animate(withDuration: 0.15, delay: 0, options: .beginFromCurrentState) {
            cell.transform = .identity
        }
    }
}

extension EateryListView: EateryFilterViewControllerDelegate {
    func eateryFilterViewController(_: EateryFilterViewController, filterDidChange filter: EateryFilter) {
        self.filter = filter
        updateEateriesFromState()
    }
}

extension EateryListView {
    typealias DataSource = UITableViewDiffableDataSource<Section, Row>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>

    enum Section {
        case main
    }

    enum Row: Hashable {
        case filter
        case eatery(eatery: Eatery, favorited: Bool)
        case label(String)
    }
}
