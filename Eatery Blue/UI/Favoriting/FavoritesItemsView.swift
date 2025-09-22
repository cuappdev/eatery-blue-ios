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

    let tableView = UITableView()

    // MARK: - Properties (data)

    /// All of the available eateries, used to find where favorite items are
    var allEateries: [Eatery] = [] {
        didSet {
            findFavorites()
        }
    }

    /// A users favorite items, taken from Core Data
    var favoriteItems: [ItemMetadata] = [] {
        didSet {
            findFavorites()
        }
    }

    private var expanded: [Int] = []
    private var itemData: [String: [String: Set<String>]] = [:]
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
        setUpTableView()
        addSubview(tableView)

        setUpConstraints()
        findFavorites()
    }

    private func setUpTableView() {
        tableView.register(FavoritesItemsTableViewCell.self, forCellReuseIdentifier: FavoritesItemsTableViewCell.reuse)
        tableView.register(ClearTableViewCell.self, forCellReuseIdentifier: ClearTableViewCell.reuse)
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 92
    }

    private func setUpConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func findFavorites() {
        let favoriteIdsSet: Set<String> = Set(favoriteItems.compactMap { $0.itemName })
        var favoriteItemsData = [(eateryName: String, timeOfDay: String, itemName: String)]()

        let today = Day()

        for eatery in allEateries {
            let eateryName = eatery.name

            for event in eatery.events {
                if event.canonicalDay != today { continue }
                guard let timeOfDay = event.description else { continue }

                let favoriteItemsInEvent = event.menu?.categories.flatMap { category in
                    category.items.filter { favoriteIdsSet.contains($0.name) }.map { item in
                        (eateryName: eateryName, timeOfDay: timeOfDay, itemName: item.name)
                    }
                } ?? []

                favoriteItemsData.append(contentsOf: favoriteItemsInEvent)
            }
        }

        for data in favoriteItemsData {
            let (eateryName, timeOfDay, itemName) = data

            if itemData[itemName] == nil {
                itemData[itemName] = [:]
            }

            if itemData[itemName]![timeOfDay] == nil {
                itemData[itemName]![timeOfDay] = []
            }

            itemData[itemName]![timeOfDay]!.insert(eateryName)
        }

        sortedFavorites = favoriteItems.sorted { itemData[$1.itemName ?? ""] == nil }

        applySnapshot(animated: true, animation: .automatic)
    }

    // MARK: - Table View Data Source

    /// Creates and returns the table view data source
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(tableView: tableView) { [weak self] tableview, indexPath, row in
            guard let self else { return UITableViewCell() }

            switch row {
            case let .item(item, expanded):
                guard let cell = tableview.dequeueReusableCell(
                    withIdentifier: FavoritesItemsTableViewCell.reuse,
                    for: indexPath
                ) as? FavoritesItemsTableViewCell else { return UITableViewCell() }

                cell.configure(item: item, expanded: expanded, itemData: itemData[item.itemName ?? ""])
                cell.selectionStyle = .none
                return cell
            case let .label(text):
                guard let cell = tableview.dequeueReusableCell(
                    withIdentifier: ClearTableViewCell.reuse,
                    for: indexPath
                ) as? ClearTableViewCell else { return UITableViewCell() }

                let label = UILabel()
                label.text = text
                label.font = .preferredFont(for: .title2, weight: .semibold)
                let container = ContainerView(content: label)
                container.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 8, right: 16)
                cell.configure(content: container)
                cell.selectionStyle = .none
                return cell
            }
        }

        return dataSource
    }

    /// Updates the table view data source, and animates if desired
    private func applySnapshot(animated: Bool = true, animation: UITableView.RowAnimation = .fade) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(
            sortedFavorites.isEmpty ? [.label("No items found")] : sortedFavorites.map { .item(
                $0,
                expanded.contains(sortedFavorites.firstIndex(of: $0) ?? 0)
            ) }
        )

        dataSource.defaultRowAnimation = animation
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}

extension FavoritesItemsView: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if itemData[sortedFavorites[indexPath.row].itemName ?? ""] == nil { return }

        if expanded.contains(indexPath.row) {
            expanded.removeAll { $0 == indexPath.row }
        } else {
            expanded.append(indexPath.row)
        }

        applySnapshot(animated: true)
    }
}

extension FavoritesItemsView {
    typealias DataSource = UITableViewDiffableDataSource<Section, Row>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>

    // For multiple sections, add to the enum
    enum Section {
        case main
    }

    // For multiple data sources, add to the enum
    enum Row: Hashable {
        case item(ItemMetadata, Bool)
        case label(String)
    }
}
