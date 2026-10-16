//
//  FavoritesItemsView.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 11/5/24.
//

import EateryModel
import UIKit

class FavoritesItemsView: UIView {
    // MARK: - Properties (view)

    private let emptyView = FavoritesEmptyView(message: "You currently have no favorite items!")
    private let tableView = UITableView()

    // MARK: - Properties (data)

    /// All of the available eateries, used to find where favorite items are
    var allEateries: [Eatery] = [] {
        didSet {
            expanded.removeAll()
            findFavorites()
        }
    }

    /// A users favorite items, taken from Core Data
    var favoriteItems: [ItemMetadata] = [] {
        didSet {
            expanded.removeAll()
            findFavorites()
        }
    }

    private var expanded: Set<Int> = []
    private var itemData: [String: [EventType: Set<String>]] = [:]
    private var sortedFavorites: [ItemMetadata] = []

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
        findFavorites()
    }

    private func setUpTableView() {
        tableView.register(FavoritesItemsTableViewCell.self, forCellReuseIdentifier: FavoritesItemsTableViewCell.reuse)
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

    private func findFavorites() {
        itemData = [:]
        let favoriteIdsSet: Set<String> = Set(favoriteItems.compactMap { $0.itemName })
        var favoriteItemsData = [(eateryName: String, type: EventType, itemName: String)]()

        let today = Day()

        for eatery in allEateries {
            let eateryName = eatery.name

            for event in eatery.events {
                if event.canonicalDay != today {
                    continue
                }

                let favoriteItemsInEvent = event.menu.flatMap { category in
                    category.items.filter { favoriteIdsSet.contains($0.name) }.map { item in
                        (eateryName: eateryName, type: event.type, itemName: item.name)
                    }
                }

                favoriteItemsData.append(contentsOf: favoriteItemsInEvent)
            }
        }

        for data in favoriteItemsData {
            let (eateryName, type, itemName) = data

            if itemData[itemName] == nil {
                itemData[itemName] = [:]
            }

            if itemData[itemName]![type] == nil {
                itemData[itemName]![type] = []
            }

            itemData[itemName]![type]!.insert(eateryName)
        }

        sortedFavorites = favoriteItems.sorted { lhs, rhs in
            let lhsAvailable = itemData[lhs.itemName ?? ""] != nil
            let rhsAvailable = itemData[rhs.itemName ?? ""] != nil
            if lhsAvailable != rhsAvailable {
                return lhsAvailable && !rhsAvailable
            }
            return (lhs.itemName ?? "") < (rhs.itemName ?? "")
        }

        emptyView.isHidden = !sortedFavorites.isEmpty
        tableView.isHidden = sortedFavorites.isEmpty
        applySnapshot(animated: true, animation: .automatic)
    }

    // MARK: - Table View Data Source

    private func makeDataSource() -> DataSource {
        return DataSource(tableView: tableView) { [weak self] tableview, indexPath, row in
            guard let self else { return UITableViewCell() }

            switch row {
            case let .item(item, expanded):
                guard let cell = tableview.dequeueReusableCell(
                    withIdentifier: FavoritesItemsTableViewCell.reuse,
                    for: indexPath
                ) as? FavoritesItemsTableViewCell else { return UITableViewCell() }

                cell.configure(item: item, expanded: expanded, itemData: itemData[item.itemName ?? ""])
                cell.onUnfavorite = { [weak self] in
                    guard let self else { return }
                    favoriteItems = AppDelegate.shared.coreDataStack.fetchFavoriteItems()
                }
                cell.selectionStyle = .none
                return cell
            }
        }
    }

    private func applySnapshot(animated: Bool = true, animation: UITableView.RowAnimation = .fade) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(
            sortedFavorites.map { item in
                .item(
                    item,
                    expanded.contains(sortedFavorites.firstIndex(of: item) ?? 0)
                )
            }
        )

        dataSource.defaultRowAnimation = animation
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}

extension FavoritesItemsView: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < sortedFavorites.count else { return }
        if itemData[sortedFavorites[indexPath.row].itemName ?? ""] == nil {
            return
        }

        if expanded.contains(indexPath.row) {
            expanded.remove(indexPath.row)
        } else {
            expanded.insert(indexPath.row)
        }

        applySnapshot(animated: true)
    }

    func tableView(
        _: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point _: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard indexPath.row < sortedFavorites.count else { return nil }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let unfavorite = UIAction(title: "Unfavorite", image: UIImage(systemName: "star.slash")) { _ in
                guard let self,
                      let cell = self.tableView.cellForRow(at: indexPath) as? FavoritesItemsTableViewCell
                else { return }
                cell.performUnfavorite()
            }
            return UIMenu(children: [unfavorite])
        }
    }
}

extension FavoritesItemsView {
    typealias DataSource = UITableViewDiffableDataSource<Section, Row>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>

    enum Section {
        case main
    }

    enum Row: Hashable {
        case item(ItemMetadata, Bool)
    }
}
