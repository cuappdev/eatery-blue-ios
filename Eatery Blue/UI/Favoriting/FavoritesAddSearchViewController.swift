//
//  FavoritesAddSearchViewController.swift
//  Eatery Blue
//
//  Created by Arielle Nudelman on 10/14/26.
//

import EateryModel
import UIKit

class FavoritesAddSearchViewController: UIViewController {
    // MARK: - Properties (view)

    private let closeButton = ButtonView(pillContent: UIImageView())
    private let popularContentView = UIView()
    private let resultsTableView = UITableView()
    private let scrollView = UIScrollView()
    private let searchBar = UISearchBar()
    private let searchContainer = UIView()
    private let searchPillBackground = UIView()
    private let separator = HDivider()

    private let popularEateriesCollection: UICollectionView
    private let popularEateriesLabel = UILabel()
    private let popularItemsLabel = UILabel()
    private let popularItemsStack = UIStackView()

    // MARK: - Properties (data)

    private var allEateries: [Eatery] = []
    private var popularEateries: [Eatery] = []
    private var popularItems: [(item: MenuItem, eatery: Eatery)] = []
    private var searchResults: [SearchResult] = []

    private enum SearchResult {
        case eatery(Eatery)
        case item(MenuItem, Eatery)
    }

    // MARK: - Init

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 280, height: 236)
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        popularEateriesCollection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.Eatery.default00
        navigationController?.navigationBar.isHidden = true

        setUpSearchContainer()
        setUpPopularContent()
        setUpResultsTable()
        setUpConstraints()

        Task {
            await loadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        searchBar.becomeFirstResponder()
    }

    // MARK: - Setup

    private func setUpSearchContainer() {
        view.addSubview(searchContainer)
        searchContainer.backgroundColor = UIColor.Eatery.default00
        searchContainer.clipsToBounds = false

        searchPillBackground.backgroundColor = UIColor.Eatery.default00
        searchPillBackground.layer.cornerRadius = 22
        searchPillBackground.layer.masksToBounds = false
        searchPillBackground.layer.shadowColor = UIColor.Eatery.primaryText.cgColor
        searchPillBackground.layer.shadowOffset = .zero
        searchPillBackground.layer.shadowRadius = 12
        searchPillBackground.layer.shadowOpacity = 0.08
        searchContainer.addSubview(searchPillBackground)

        searchBar.placeholder = "Search for grub..."
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        searchBar.returnKeyType = .search
        searchBar.enablesReturnKeyAutomatically = false
        searchBar.setImage(UIImage(), for: .clear, state: .normal)
        searchBar.searchTextField.backgroundColor = .clear
        searchBar.searchTextField.borderStyle = .none
        searchContainer.addSubview(searchBar)

        let closeConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        closeButton.content.image = UIImage(systemName: "xmark", withConfiguration: closeConfig)
        closeButton.content.tintColor = UIColor.Eatery.primaryText
        closeButton.content.contentMode = .scaleAspectFit
        closeButton.shadowColor = UIColor.Eatery.primaryText
        closeButton.shadowOffset = .zero
        closeButton.shadowRadius = 12
        closeButton.shadowOpacity = 0.08
        closeButton.backgroundColor = UIColor.Eatery.default00
        closeButton.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        closeButton.buttonPress { [weak self] _ in
            self?.dismissSearch()
        }
        searchContainer.addSubview(closeButton)

        searchContainer.addSubview(separator)
    }

    private func setUpPopularContent() {
        view.addSubview(scrollView)
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        scrollView.addSubview(popularContentView)

        popularEateriesLabel.text = "Popular Eateries"
        popularEateriesLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        popularEateriesLabel.textColor = UIColor.Eatery.primaryText
        popularContentView.addSubview(popularEateriesLabel)

        popularEateriesCollection.backgroundColor = .clear
        popularEateriesCollection.showsHorizontalScrollIndicator = false
        popularEateriesCollection.clipsToBounds = false
        popularEateriesCollection.dataSource = self
        popularEateriesCollection.delegate = self
        popularEateriesCollection.register(
            FavoritesSearchEateryCell.self,
            forCellWithReuseIdentifier: FavoritesSearchEateryCell.reuse
        )
        popularContentView.addSubview(popularEateriesCollection)

        popularItemsLabel.text = "Popular Items"
        popularItemsLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        popularItemsLabel.textColor = UIColor.Eatery.primaryText
        popularContentView.addSubview(popularItemsLabel)

        popularItemsStack.axis = .vertical
        popularItemsStack.spacing = 12
        popularContentView.addSubview(popularItemsStack)
    }

    private func setUpResultsTable() {
        view.addSubview(resultsTableView)
        resultsTableView.isHidden = true
        resultsTableView.separatorStyle = .none
        resultsTableView.backgroundColor = UIColor.Eatery.default00
        resultsTableView.dataSource = self
        resultsTableView.delegate = self
        resultsTableView.keyboardDismissMode = .onDrag
        resultsTableView.rowHeight = UITableView.automaticDimension
        resultsTableView.estimatedRowHeight = 86
    }

    private func setUpConstraints() {
        searchContainer.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        searchBar.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.trailing.equalTo(closeButton.snp.leading).offset(-12)
            make.height.equalTo(44)
            make.bottom.equalTo(separator.snp.top).offset(-20)
        }

        searchPillBackground.snp.makeConstraints { make in
            make.leading.trailing.equalTo(searchBar)
            make.centerY.equalTo(searchBar)
            make.height.equalTo(44)
        }

        closeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(searchBar)
            make.width.height.equalTo(44)
        }

        separator.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(1)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(searchContainer.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        view.bringSubviewToFront(searchContainer)

        popularContentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        popularEateriesLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        popularEateriesCollection.snp.makeConstraints { make in
            make.top.equalTo(popularEateriesLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(236)
        }

        popularItemsLabel.snp.makeConstraints { make in
            make.top.equalTo(popularEateriesCollection.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        popularItemsStack.snp.makeConstraints { make in
            make.top.equalTo(popularItemsLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(24)
        }

        resultsTableView.snp.makeConstraints { make in
            make.top.equalTo(searchContainer.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - Data

    private func loadData() async {
        do {
            let eateries = try await Networking.default.loadAllEatery()
            allEateries = eateries
            popularEateries = computePopularEateries(from: eateries)
            popularItems = computePopularItems(from: eateries)

            await MainActor.run {
                popularEateriesCollection.reloadData()
                rebuildPopularItemsStack()
            }
        } catch {
            logger.error("\(#function): \(error)")
        }
    }

    private func computePopularEateries(from eateries: [Eatery]) -> [Eatery] {
        // Show all dining halls (not only currently open), sorted A–Z for browsing.
        eateries.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private func computePopularItems(from eateries: [Eatery]) -> [(item: MenuItem, eatery: Eatery)] {
        // Use every menu event in the loaded payload (not just meals open right now).
        var counts: [String: (count: Int, item: MenuItem, eatery: Eatery)] = [:]

        for eatery in eateries {
            for event in eatery.events {
                for category in event.menu {
                    for item in category.items {
                        let key = item.name.lowercased()
                        if let existing = counts[key] {
                            counts[key] = (existing.count + 1, existing.item, existing.eatery)
                        } else {
                            counts[key] = (1, item, eatery)
                        }
                    }
                }
            }
        }

        return counts.values
            .sorted {
                if $0.count != $1.count {
                    return $0.count > $1.count
                }
                return $0.item.name.localizedCaseInsensitiveCompare($1.item.name) == .orderedAscending
            }
            .prefix(20)
            .map { ($0.item, $0.eatery) }
    }

    private func rebuildPopularItemsStack() {
        popularItemsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for entry in popularItems {
            let row = FavoritesSearchItemRow()
            row.configure(item: entry.item, eatery: entry.eatery)
            popularItemsStack.addArrangedSubview(row)
        }
    }

    private func performSearch(_ text: String) {
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let showingResults = !query.isEmpty
        scrollView.isHidden = showingResults
        resultsTableView.isHidden = !showingResults

        guard showingResults else {
            searchResults = []
            resultsTableView.reloadData()
            return
        }

        let lowered = query.lowercased()
        var results: [SearchResult] = []
        var seenItems = Set<String>()

        for eatery in allEateries where eatery.name.lowercased().contains(lowered)
            || (eatery.location.validated() ?? eatery.location).lowercased().contains(lowered) {
            results.append(.eatery(eatery))
        }

        for eatery in allEateries {
            for event in eatery.events {
                for category in event.menu {
                    for item in category.items where item.name.lowercased().contains(lowered) {
                        let key = "\(item.name.lowercased())|\(eatery.cornellId ?? eatery.id)"
                        if seenItems.insert(key).inserted {
                            results.append(.item(item, eatery))
                        }
                    }
                }
            }
        }

        searchResults = Array(results.prefix(60))
        resultsTableView.reloadData()
    }

    private func dismissSearch() {
        searchBar.resignFirstResponder()
        navigationController?.popViewController(animated: true)
        if navigationController == nil {
            dismiss(animated: true)
        }
    }
}

// MARK: - UISearchBarDelegate

extension FavoritesAddSearchViewController: UISearchBarDelegate {
    func searchBar(_: UISearchBar, textDidChange searchText: String) {
        performSearch(searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - Popular Eateries Collection

extension FavoritesAddSearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        popularEateries.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FavoritesSearchEateryCell.reuse,
            for: indexPath
        ) as? FavoritesSearchEateryCell else {
            return UICollectionViewCell()
        }

        let eatery = popularEateries[indexPath.item]
        let favorited = AppDelegate.shared.coreDataStack.metadata(eateryId: eatery.cornellId).isFavorite
        cell.configure(eatery: eatery, favorited: favorited)
        return cell
    }
}

// MARK: - Results Table

extension FavoritesAddSearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        searchResults.count
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = FavoritesSearchItemRow()
        switch searchResults[indexPath.row] {
        case let .eatery(eatery):
            row.configure(eatery: eatery)
        case let .item(item, eatery):
            row.configure(item: item, eatery: eatery)
        }

        let container = ContainerView(content: row)
        container.layoutMargins = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)

        let cell = ClearTableViewCell(content: container)
        cell.selectionStyle = .none
        return cell
    }
}
