//
//  FavoritesItemsView.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 11/5/24.
//

import EateryModel
import UIKit

class FavoritesItemsView: UIView {

    // MARK: - Properties (View)

    let tableView = UITableView()

    // MARK: - Properties (Data)

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

    // MARK: - Init

    init() {
        super.init(frame: .zero)

        setUpSelf()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpSelf() {
        setUpTableView()
        self.addSubview(tableView)

        setUpConstraints()
        findFavorites()
    }

    private func setUpTableView() {
        tableView.register(FavoritesItemsTableViewCell.self, forCellReuseIdentifier: FavoritesItemsTableViewCell.reuse)
        tableView.dataSource = self
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

        sortedFavorites = favoriteItems.sorted { itemData[$0.itemName ?? ""] == nil && itemData[$1.itemName ?? ""] == nil }
        tableView.reloadData()
    }

}

extension FavoritesItemsView: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedFavorites.isEmpty ? 1 : sortedFavorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if sortedFavorites.isEmpty {
            let label = UILabel()
            label.text = "No items found..."
            label.font = .preferredFont(for: .title2, weight: .semibold)
            let container = ContainerView(content: label)
            container.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 8, right: 16)

            let cell = ClearTableViewCell(content: container)
            cell.selectionStyle = .none
            return cell
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoritesItemsTableViewCell.reuse, for: indexPath) as? FavoritesItemsTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none


        cell.configure(item: sortedFavorites[indexPath.row], expanded: expanded.contains(indexPath.row), itemData: itemData[sortedFavorites[indexPath.row].itemName ?? ""])

        return cell
    }

}

extension FavoritesItemsView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if itemData[sortedFavorites[indexPath.row].itemName ?? ""] == nil { return }

        if expanded.contains(indexPath.row) {
            expanded.removeAll { $0 == indexPath.row }
        } else {
            expanded.append(indexPath.row)
        }

        tableView.reloadRows(at: [indexPath], with: .fade)
    }

}
