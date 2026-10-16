//
//  FavoritesEateriesView.swift
//  Eatery Blue
//
//  Created by Arielle Nudelman on 10/14/26.
//

import EateryModel
import UIKit

class FavoritesEateriesView: UIView {
    // MARK: - Properties (view)

    private let emptyView = FavoritesEmptyView(message: "You currently have no favorite eateries!")
    private let tableView = UITableView()

    // MARK: - Properties (data)

    var eateries: [Eatery] = [] {
        didSet {
            expanded.removeAll()
            sortEateries()
        }
    }

    var navigationController: UINavigationController?

    private var expanded: Set<Int> = []
    private var sortedEateries: [Eatery] = []

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

    // MARK: - Setup

    private func setUpSelf() {
        backgroundColor = UIColor.Eatery.default00

        setUpTableView()
        addSubview(tableView)

        addSubview(emptyView)
        emptyView.isHidden = true

        setUpConstraints()
        sortEateries()
    }

    private func setUpTableView() {
        tableView.register(
            FavoritesEateryTableViewCell.self,
            forCellReuseIdentifier: FavoritesEateryTableViewCell.reuse
        )
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.Eatery.default00
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 82
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -16)
    }

    private func setUpConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func sortEateries() {
        let today = Day()
        sortedEateries = eateries.sorted { lhs, rhs in
            let lhsAvailable = lhs.events.contains { $0.canonicalDay == today }
            let rhsAvailable = rhs.events.contains { $0.canonicalDay == today }
            if lhsAvailable != rhsAvailable {
                return lhsAvailable && !rhsAvailable
            }
            return lhs.name < rhs.name
        }

        emptyView.isHidden = !sortedEateries.isEmpty
        tableView.isHidden = sortedEateries.isEmpty
        applySnapshot(animated: true)
    }

    // MARK: - Table View Data Source

    private func makeDataSource() -> DataSource {
        return DataSource(tableView: tableView) { [weak self] tableView, indexPath, row in
            guard let self else { return UITableViewCell() }

            switch row {
            case let .eatery(eatery, expanded):
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: FavoritesEateryTableViewCell.reuse,
                    for: indexPath
                ) as? FavoritesEateryTableViewCell else { return UITableViewCell() }

                cell.configure(eatery: eatery, expanded: expanded)
                cell.onUnfavorite = { [weak self] in
                    guard let self else { return }
                    eateries = eateries.filter { $0.cornellId != eatery.cornellId }
                }
                cell.selectionStyle = .none
                return cell
            }
        }
    }

    private func applySnapshot(animated: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(
            sortedEateries.enumerated().map { index, eatery in
                .eatery(eatery, expanded.contains(index))
            }
        )
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}

extension FavoritesEateriesView: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < sortedEateries.count else { return }
        let eatery = sortedEateries[indexPath.row]
        let availableToday = eatery.events.contains { $0.canonicalDay == Day() }

        if availableToday {
            if expanded.contains(indexPath.row) {
                expanded.remove(indexPath.row)
            } else {
                expanded.insert(indexPath.row)
            }
            applySnapshot(animated: true)
        } else {
            let pageVC = EateryPageViewController(eateries: sortedEateries, index: indexPath.row)
            navigationController?.hero.isEnabled = true
            navigationController?.heroNavigationAnimationType = .fade
            navigationController?.pushViewController(pageVC, animated: true)
        }
    }

    func tableView(
        _: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point _: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard indexPath.row < sortedEateries.count else { return nil }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let unfavorite = UIAction(title: "Unfavorite", image: UIImage(systemName: "star.slash")) { _ in
                guard let self,
                      let cell = self.tableView.cellForRow(at: indexPath) as? FavoritesEateryTableViewCell
                else { return }
                cell.performUnfavorite()
            }
            return UIMenu(children: [unfavorite])
        }
    }
}

extension FavoritesEateriesView {
    typealias DataSource = UITableViewDiffableDataSource<Section, Row>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>

    enum Section {
        case main
    }

    enum Row: Hashable {
        case eatery(Eatery, Bool)
    }
}
