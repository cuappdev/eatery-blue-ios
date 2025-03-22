//
//  HomeViewController.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 1/5/25.
//

import Combine
import EateryModel
import UIKit

class HomeViewController: UIViewController {

    // MARK: - Properties (view)

    private let collectionView: UICollectionView
    private let compareMenusButton = CompareMenusButton()
    private let compareMenusOnboarding = CompareMenusExternalOnboardingView()
    private let favoritesCarousel = CarouselView()
    private let navigationView = HomeNavigationView()


    // MARK: - Properties (data)

    private var allEateries: [Eatery] = []
    private var cancellables: Set<AnyCancellable> = []
    private lazy var dataSource = makeDataSource()
    private var favoritesObserver: NSObjectProtocol?
    private var filter = EateryFilter()
    private let filterController = EateryFilterViewController()
    private var headerHeight: CGFloat = Constants.maxHeaderHeight
    private var isLoading = true
    private var previousScrollOffset: CGFloat = 0
    private var selectedDisplayStyle: DisplayStyle = {
        DisplayStyle(rawValue: UserDefaults.standard.integer(forKey: UserDefaultsKeys.preferedDisplayStyle)) ?? .list
    }()
    private var shownEateries: [Eatery] = []

    // MARK: - Constants

    struct Constants {
        static let carouselViewLayoutMargins = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        static let customViewLayoutMargins = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        static let minHeaderHeight: CGFloat = 44
        static let maxHeaderHeight: CGFloat = 98
        static let loadingHeaderHeight: CGFloat = maxHeaderHeight + 52
        static let collectionViewTopPadding: CGFloat = 8
        static let collectionViewSectionPadding: CGFloat = 16
        static let isTesting = false
    }

    // MARK: - Init

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionHeadersPinToVisibleBounds = true
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Deinit

    deinit {
        self.removeObserver(current: favoritesObserver)
    }

    // MARK: - Setup

    override func viewDidLoad() {
        super.viewDidLoad()

        RootViewController.setStatusBarStyle(.lightContent)


        view.addSubview(collectionView)
        setUpCollectionView()

        view.addSubview(navigationView)
        setUpNavigationView()

        view.addSubview(compareMenusButton)
        setUpCompareMenusButton()

        setUpUserLocationSubscription()
        setUpFavNotification()
        setUpConstraints()

        view.layoutIfNeeded()

        Task {
            do {
                startLoading()
                try await updateSimpleEateriesFromNetworking()
                stopLoading()
                trySetUpCompareMenusOnboarding()
            } catch {
                logger.error("\(#function): \(error)")
            }
        }

        // For caching purposes. Although we might not need it now we will likely need it in a bit
        Task {
            await updateAllEateriesFromNetworking()
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        collectionView.contentInset.top = Constants.maxHeaderHeight + view.safeAreaInsets.top
        updateNavHeaderViewHeight()
    }

    private func setUpCollectionView() {
        collectionView.backgroundColor = .Eatery.offWhite
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.delegate = self
        collectionView.contentInset.bottom = tabBarController?.tabBar.frame.height ?? 0
        collectionView.showsVerticalScrollIndicator = false

        collectionView.register(EateryCardShimmerCollectionViewCell.self, forCellWithReuseIdentifier: EateryCardShimmerCollectionViewCell.reuse)

        collectionView.register(EateryLargeCardView.self, forCellWithReuseIdentifier: EateryLargeCardView.reuse)
        collectionView.register(EaterySmallCardView.self, forCellWithReuseIdentifier: EaterySmallCardView.reuse)
        collectionView.register(ClearCollectionViewCell.self, forCellWithReuseIdentifier: ClearCollectionViewCell.reuse)

        setUpFilterController()
    }

    private func setUpNavigationView() {
        navigationView.logoRefreshControl.delegate = self
        navigationView.setFadeInProgress(0)
        navigationView.searchButton.tap { [self] _ in
            let searchViewController = HomeSearchModelController()
            navigationController?.hero.isEnabled = false
            navigationController?.pushViewController(searchViewController, animated: true)
        }
        
        navigationView.notificationButton.onTap { [self] _ in
            let notifHubViewController = NotificationsHubViewController()
            
            navigationController?.pushViewController(notifHubViewController, animated: true)
        }

        navigationView.logoRefreshControl.addTarget(self, action: #selector(didRefresh), for: .valueChanged)
    }

    private func setUpCompareMenusButton() {
        compareMenusButton.buttonPress { [weak self] _ in
            guard let self else { return }

            let viewController = CompareMenusSheetViewController(parentNavigationController: navigationController, selectedEateries: [])
            viewController.setUpSheetPresentation()
            tabBarController?.present(viewController, animated: true)
            AppDevAnalytics.shared.logFirebase(CompareMenusButtonPressPayload(entryPage: "HomeViewController"))
        }
    }

    private func setUpFilterController() {
        addChild(filterController)
        filterController.delegate = self
        filterController.didMove(toParent: self)
    }

    private func setUpUserLocationSubscription() {
        LocationManager.shared.userLocationDidChange.sink { [self] _ in
            applySnapshot()
        }.store(in: &cancellables)
    }

    private func setUpFavNotification() {
        self.addFavoriteObservation(current: &favoritesObserver) { [weak self] _ in
            guard let self else { return }

            let favoriteEateries = allEateries.filter {
                AppDelegate.shared.coreDataStack.metadata(eateryId: $0.id).isFavorite
            }.sorted { lhs, rhs in
                if lhs.isOpen == rhs.isOpen {
                    return lhs.name < rhs.name
                } else {
                    return lhs.isOpen && !rhs.isOpen
                }
            }

            favoritesCarousel.eateries = favoriteEateries

            let _ = updateFavoritesCarousel()
            applySnapshot()
        }
    }

    private func trySetUpCompareMenusOnboarding() {
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.didExternallyOnboardCompareMenus) { return }

        compareMenusOnboarding.layer.opacity = 0.01
        navigationController?.tabBarController?.parent?.view.addSubview(compareMenusOnboarding)
        compareMenusOnboarding.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self else { return }
            compareMenusOnboarding.layer.opacity = 1
        }

        compareMenusOnboarding.compareMenusButton.tap { [weak self] _ in
            guard let self else { return }

            compareMenusOnboarding.dismiss()
            let viewController = CompareMenusSheetViewController(parentNavigationController: navigationController, selectedEateries: [])
            viewController.setUpSheetPresentation()
            tabBarController?.present(viewController, animated: true)
        }
    }


    private func setUpConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        navigationView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(view.safeAreaInsets.top)
        }

        compareMenusButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(108)
        }
    }

    // MARK: - Actions

    func scrollToTop(animated: Bool) {
        collectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
    }

    @objc private func didRefresh(_ sender: LogoRefreshControl) {
        startLoading()
        LocationManager.shared.requestLocation()

        Task {
            await withThrowingTaskGroup(of: Void.self) { [weak self] group in
                guard let self else { return }
                group.addTask { [weak self] in
                    guard let self else { return }

                    do {
                        try await updateSimpleEateriesFromNetworking()
                    } catch {
                        logger.error("\(#function): \(error)")
                    }
                }
                // Create a task to let the logo view do one complete animation cycle
                group.addTask { [weak self] in
                    guard self != nil else { return }

                    try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                }
            }

            stopLoading()
            sender.endRefreshing()
        }
    }

    /// Start loading all eateries in the background, will be cached if needs to be refetched
    private func updateAllEateriesFromNetworking() async {
        do {
            let _ = Constants.isTesting ? DummyData.eateries : try await Networking.default.loadAllEatery()
        } catch {
            logger.error("\(error)")
        }
    }

    /// Request the simple eateries from the networking layer.
    private func updateSimpleEateriesFromNetworking() async throws {
        let eateries = Constants.isTesting ? DummyData.eateries : try await Networking.default.loadSimpleEateries()
        allEateries = eateries.filter { eatery in
            return !eatery.name.isEmpty
        }.sorted(by: {
            return $0.isOpen == $1.isOpen ? $0.name < $1.name : $0.isOpen
        })
    }

    /// Returns the favorites carousel using the core data stack. Returns nil if the carousel is empty.
    private func updateFavoritesCarousel() -> CarouselView? {
        let favoritesViewController = FavoritesViewController()
        favoritesCarousel.title = "Favorites"
        favoritesCarousel.truncateAfter = 3
        favoritesCarousel.navigationController = navigationController
        favoritesCarousel.viewControllerToPush = favoritesViewController
        let favoriteEateries = allEateries.filter {
            AppDelegate.shared.coreDataStack.metadata(eateryId: $0.id).isFavorite
        }.sorted { lhs, rhs in
            if lhs.isOpen == rhs.isOpen {
                return lhs.name < rhs.name
            } else {
                return lhs.isOpen && !rhs.isOpen
            }
        }

        favoritesCarousel.backgroundColor = .clear
        favoritesCarousel.eateries = favoriteEateries
        return favoriteEateries.count > 0 ? favoritesCarousel: nil
    }


    // MARK: - Utils

    /// Pushes the page view controller at the given index
    private func pushViewController(eateryIndex: Int) {
        let pageVC = EateryPageViewController(eateries: shownEateries, index: eateryIndex)
        navigationController?.hero.isEnabled = true
        navigationController?.hero.navigationAnimationType = .fade
        navigationController?.pushViewController(pageVC, animated: true)
    }

    /// Animate all of the cells loading in
    func animateCellLoading() {
        let collectionViewCells = collectionView.visibleCells

        // sort the cells by the section and then index
        let sortedCells = collectionViewCells.sorted { lhs, rhs in
            let lhsIdxPth = collectionView.indexPath(for: lhs)!
            let rhsIdxPth = collectionView.indexPath(for: rhs)!
            if lhsIdxPth.section == rhsIdxPth.section {
                return lhsIdxPth.row < rhsIdxPth.row
            }

            return lhsIdxPth.section < rhsIdxPth.section
        }

        var delayCounter = 0

        sortedCells.forEach { cell in
            cell.transform = CGAffineTransform(translationX: 0, y: 82)
            cell.alpha = 0
        }

        for index in 0..<sortedCells.count {
            UIView.animate(withDuration: 1.3, delay: 0.1 * Double(delayCounter), usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                sortedCells[index].transform = CGAffineTransform.identity
                sortedCells[index].alpha = 1
            }, completion: nil)
            delayCounter += 1
        }
    }

    /// Update navigation header height
    func updateNavHeaderViewHeight() {
        navigationView.snp.updateConstraints { make in
            make.height.equalTo(view.safeAreaInsets.top + headerHeight)
        }
    }

    private func startLoading() {
        isLoading = true
        applySnapshot(animated: true)
        view.isUserInteractionEnabled = false
    }

    private func stopLoading() {
        isLoading = false
        applySnapshot(animated: false)
        animateCellLoading()
        view.isUserInteractionEnabled = true
    }

    // MARK: - Collection View Data Source

    /// Creates and returns the table view data source
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { [weak self] (tableview, indexPath, item) in
            guard let self else { return UICollectionViewCell() }

            switch item {
            case .largeEateryCard(eatery: let eatery, favorited: let favorited):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EateryLargeCardView.reuse, for: indexPath) as? EateryLargeCardView else { return UICollectionViewCell() }
                cell.configure(eatery: eatery, favorited: favorited)
                return cell
            case .smallEateryCard(eatery: let eatery, favorited: let favorited):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EaterySmallCardView.reuse, for: indexPath) as? EaterySmallCardView else { return UICollectionViewCell() }
                cell.configure(eatery: eatery, favorited: favorited)
                return cell
            case .loadingCard(isLarge: _, key: _):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EateryCardShimmerCollectionViewCell.reuse, for: indexPath) as? EateryCardShimmerCollectionViewCell else { return UICollectionViewCell() }
                cell.configure()
                return cell
            default:
                break
            }

            guard let cell = tableview.dequeueReusableCell(withReuseIdentifier: ClearCollectionViewCell.reuse, for: indexPath) as? ClearCollectionViewCell else { return UICollectionViewCell() }

            switch item {
            case .searchBar:
                let searchBar = UISearchBar()
                searchBar.delegate = self
                searchBar.placeholder = "Search for grub..."
                searchBar.backgroundImage = UIImage()
                searchBar.hero.id = "searchBar"
                cell.configure(content: searchBar)
            case .customView(let view, _, _):
                let container = ContainerView(content: view)
                container.layoutMargins = Constants.customViewLayoutMargins
                cell.configure(content: container)
            case .titleLabel(title: let title):
                let label = UILabel()
                label.text = title
                label.font = .preferredFont(for: .title2, weight: .semibold)
                let container = ContainerView(content: label)
                cell.configure(content: container)
            case .loadingLabel(title: let title):
                let label = UILabel()
                label.text = title
                label.textColor = UIColor.Eatery.gray02
                label.font = .preferredFont(for: .title2, weight: .semibold)
                let container = ContainerView(content: label)
                cell.configure(content: container)
            case .carouselView(let carouselView):
                let container = ContainerView(content: carouselView)
                cell.configure(content: container)
            case .loadingCarousel:
                let stackView = UIStackView()
                stackView.axis = .horizontal
                stackView.spacing = 16
                stackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 0)
                stackView.isLayoutMarginsRelativeArrangement = true
                for _ in 0...1 {
                    let view = EateryCardShimmerCollectionViewCell()
                    stackView.addArrangedSubview(view)
                    view.snp.makeConstraints { make in
                        make.width.equalTo(312)
                    }
                }

                let container = ContainerView(content: stackView)
                cell.configure(content: container)
            default:
                break
            }
            return cell
        }

        return dataSource
    }

    /// Updates the table view data source, and animates if desired
    private func applySnapshot(animated: Bool = true) {
        var snapshot = Snapshot()

        let coreDataStack = AppDelegate.shared.coreDataStack
        var currentEateries: [Eatery] = []

        // Tool Bar (Search bar and Filters)
        snapshot.appendSections([.toolbar])

        filterController.view.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        snapshot.appendItems([
            .searchBar,
            .customView(view: filterController.view, height: 44)
        ], toSection: .toolbar)

        // Carousel (favorites carousel)
        snapshot.appendSections([.carousel])

        if isLoading {
            snapshot.appendItems([
                .loadingLabel(title: "Finding flavorful food..."),
                .loadingCarousel
            ], toSection: .carousel)
        } else {
            if !filter.isEnabled {
                if let favoritesCarousel = updateFavoritesCarousel() {
                    snapshot.appendItems([.carouselView(favoritesCarousel)], toSection: .carousel)
                }

                currentEateries = allEateries
            }
        }

        // Main section (eateries)
        snapshot.appendSections([.main])

        if isLoading {
            snapshot.appendItems([.loadingLabel(title: "Checking for chow...")], toSection: .main)
            for i in 0..<4 {
                snapshot.appendItems([.loadingCard(isLarge: true, key: i)], toSection: .main)
            }

            dataSource.apply(snapshot, animatingDifferences: animated)
            return
        }

        if !filter.isEnabled {
            currentEateries = allEateries
        } else {
            let predicate = filter.predicate(userLocation: LocationManager.shared.userLocation, departureDate: Date())
            let filteredEateries = allEateries.filter{
                predicate.isSatisfied(by: $0, metadata: coreDataStack.metadata(eateryId: $0.id))
            }

            currentEateries = filteredEateries

            if filteredEateries.isEmpty {
                snapshot.appendItems([.titleLabel(title: "No eateries found...")], toSection: .main)
            }
        }

        LocationManager.shared.$userLocation
        .sink { userLocation in
                currentEateries = currentEateries.sorted(by: { eatery1, eatery2 in
                let dist1 = eatery1.walkTime(userLocation: userLocation)
                let dist2 = eatery2.walkTime(userLocation: userLocation)
                guard let dist1, let dist2 else { return true }

                return dist1 < dist2
            })
        }
        .store(in: &cancellables)

        let label = UILabel()
        label.text = filter.isEnabled ? "Filtered Eateries" : "All Eateries"
        label.font = .preferredFont(for: .title2, weight: .semibold)

        let selectionButtons = MiniSelectionView()
        selectionButtons.addButton(DisplayStyle.list.rawValue, image: UIImage(named: "Burger")!, padding: 8)
        selectionButtons.addButton(DisplayStyle.grid.rawValue, image: UIImage(systemName: "square.grid.2x2")!, padding: 4)
        selectionButtons.onTap = { [weak self] selection in
            guard let self else { return }

            if selection == DisplayStyle.list.rawValue {
                selectedDisplayStyle = .list
            } else {
                selectedDisplayStyle = .grid
            }

            UserDefaults.standard.set(selectedDisplayStyle.rawValue, forKey: UserDefaultsKeys.preferedDisplayStyle)

            applySnapshot()
        }

        selectionButtons.selectButton(selectedDisplayStyle.rawValue)

        let container = UIView()
        container.addSubview(label)
        container.addSubview(selectionButtons)
        label.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
        }

        selectionButtons.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.equalTo(label.snp.trailing)
        }
        
        selectionButtons.layoutIfNeeded()

        snapshot.appendItems([.customView(view: container, height: 44, padding: 16)], toSection: .main)

        // favorites
        let favoriteEateries = allEateries.filter {
            coreDataStack.metadata(eateryId: $0.id).isFavorite
        }

        let openEateries = currentEateries.filter(\.isOpen)
        if !openEateries.isEmpty {
            switch selectedDisplayStyle {
            case .list:
                snapshot.appendItems(openEateries.map({
                    .largeEateryCard(eatery: $0, favorited: favoriteEateries.contains($0))
                }), toSection: .main)
            case .grid:
                snapshot.appendItems(openEateries.map({
                    .smallEateryCard(eatery: $0, favorited: favoriteEateries.contains($0))
                }), toSection: .main)
            }
        }

        let closedEateries = currentEateries.filter { !$0.isOpen }
        if !closedEateries.isEmpty {
            switch selectedDisplayStyle {
            case .list:
                snapshot.appendItems(closedEateries.map({
                    .largeEateryCard(eatery: $0, favorited: favoriteEateries.contains($0))
                }), toSection: .main)
            case .grid:
                snapshot.appendItems(closedEateries.map({
                    .smallEateryCard(eatery: $0, favorited: favoriteEateries.contains($0))
                }), toSection: .main)
            }
        }

        self.shownEateries = openEateries + closedEateries
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

}

// MARK: - Collection View Extensions

extension HomeViewController {

    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>


    enum Section {
        case toolbar
        case carousel
        case main
    }

    enum Item: Hashable {
        case searchBar
        case customView(view: UIView, height: CGFloat, padding: CGFloat = 0)
        case carouselView(CarouselView)
        case titleLabel(title: String)
        case smallEateryCard(eatery: Eatery, favorited: Bool)
        case largeEateryCard(eatery: Eatery, favorited: Bool)
        case loadingCarousel
        case loadingLabel(title: String)
        case loadingCard(isLarge: Bool, key: Int)

        func getSize(collectionView: UICollectionView) -> CGSize {
            var width = collectionView.contentSize.width - Constants.collectionViewSectionPadding * 2
            var height = collectionView.bounds.width * 7 / 12
            switch self {
            case .titleLabel, .loadingLabel:
                height = 46
                break
            case .searchBar:
                width = width + 8 * 2
                height = 46
                break
            case .carouselView:
                width = collectionView.contentSize.width
                height = 268
                break
            case .loadingCarousel:
                width = collectionView.contentSize.width
                height = 268 - 46
            case .customView(_, let h, let padding):
                width = collectionView.contentSize.width - 2 * padding
                height = h
                break
            case .largeEateryCard:
                height = width * 15 / 24
                break
            case .smallEateryCard:
                width = (width - 12) / 2
                height = width
                break
            case .loadingCard(let isLarge, _):
                if isLarge {
                    height = width * 15 / 24
                } else {
                    width = collectionView.contentSize.width / 2
                    height = width
                }
                break
            }

            // Account for edge case where width or height is less than zero
            return CGSize(width: max(0, width), height: max(0, height))
        }
    }

    enum Status {
        case open
        case closed
    }

    enum DisplayStyle: Int {
        case list = 0
        case grid = 1

        var description: String {
            switch self {
            case .list:
                return "List"
            case .grid:
                return "Grid"
            }
        }
    }

}

extension HomeViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .largeEateryCard(let eatery, let _), .smallEateryCard(let eatery, let _):
            for (index, element) in shownEateries.enumerated() {
                if eatery.id == element.id {
                    pushViewController(eateryIndex: index)
                    break
                }
            }
        default:
            break
        }
    }

}

extension HomeViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return .zero }
        return item.getSize(collectionView: collectionView)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch dataSource.sectionIdentifier(for: section) {
        case .main:
            return UIEdgeInsets(top: Constants.collectionViewSectionPadding, left: Constants.collectionViewSectionPadding, bottom: 0, right: Constants.collectionViewSectionPadding)
        case .toolbar:
            return UIEdgeInsets(top: Constants.collectionViewTopPadding, left: 0, bottom: 0, right: 0)
        default:
            return .zero
        }
    }

}

// MARK: - UIScrollViewDelegate

extension HomeViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        handleHeader(scrollView)
        handleCompareMenusButton(scrollView)
    }

    private func handleHeader(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y + collectionView.contentInset.top

        // Calculate the new header height
        var newHeight = max(Constants.maxHeaderHeight - offset, Constants.minHeaderHeight)

        // if we are loading restrict the new height to the loading height
        if navigationView.logoRefreshControl.isRefreshing {
            newHeight = max(Constants.loadingHeaderHeight, newHeight)
        }

        // Update the header height
        if headerHeight != newHeight {
            headerHeight = newHeight
            updateNavHeaderViewHeight()
        }

        // we don't want to update the fade if we are refreshing
        if navigationView.logoRefreshControl.isRefreshing { return }

        if offset > (Constants.minHeaderHeight + Constants.maxHeaderHeight) / 2 - Constants.minHeaderHeight {
            navigationView.setFadeInProgress(1, animated: true)
        } else {
            navigationView.setFadeInProgress(0, animated: true)
        }

        let pullProgress = (-offset - 22) / 66
        navigationView.logoRefreshControl.setPullProgress(pullProgress)

        let fadeDistance = navigationView.logoRefreshControl.bounds.height
        let progress = max(0, min(1, 1 - offset / fadeDistance))
        navigationView.logoRefreshControl.alpha = progress
        navigationView.largeTitleLabel.alpha = progress
        navigationView.notificationButton.alpha = progress
    }

    private func handleCompareMenusButton(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < previousScrollOffset - 150 {
            compareMenusButton.collapse()
            previousScrollOffset = scrollView.contentOffset.y
        } else if scrollView.contentOffset.y > previousScrollOffset + 150 {
            compareMenusButton.expand()
            previousScrollOffset = scrollView.contentOffset.y
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        handlePullToRefresh(scrollView)
        handleSnapping(scrollView, velocity: velocity, targetContentOffset: targetContentOffset)
    }

    private func handleSnapping(_ scrollView: UIScrollView, velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let currentPosition = scrollView.contentOffset.y
        let decelerationRate = scrollView.decelerationRate.rawValue
        var offset = currentPosition + velocity.y * decelerationRate / (1 - decelerationRate) + scrollView.contentInset.top
        if offset < 0 { return }

        if offset < (Constants.maxHeaderHeight - Constants.minHeaderHeight) / 2 {
            offset = 0
        } else if offset < (Constants.maxHeaderHeight - Constants.minHeaderHeight) {
            offset = Constants.maxHeaderHeight - Constants.minHeaderHeight
        }

        targetContentOffset.pointee = CGPoint(x: 0, y: offset - scrollView.contentInset.top)
    }

    private func handlePullToRefresh(_ scrollView: UIScrollView) {
        let deltaFromTop = scrollView.contentOffset.y + scrollView.contentInset.top
        let pullProgress = (-deltaFromTop - 22) / 66

        if pullProgress > 1.1 {
            navigationView.logoRefreshControl.beginRefreshing()
        }
    }

}

// MARK: - LogoRefreshControlDelegate

extension HomeViewController: LogoRefreshControlDelegate {

    func logoRefreshControlDidBeginRefreshing(_ sender: LogoRefreshControl) {
        collectionView.contentInset.top = Constants.loadingHeaderHeight + view.safeAreaInsets.top
    }

    func logoRefreshControlDidEndRefreshing(_ sender: LogoRefreshControl) {
        headerHeight = Constants.maxHeaderHeight
        updateNavHeaderViewHeight()
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self else { return }

            collectionView.contentInset.top = Constants.maxHeaderHeight + view.safeAreaInsets.top
            view.layoutIfNeeded()
        }

        navigationView.logoRefreshControl.setPullProgress(0)
    }

}

// MARK: - UISearchBarDelegate

extension HomeViewController: UISearchBarDelegate {

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        let viewController = HomeSearchModelController()
        navigationController?.hero.isEnabled = true
        navigationController?.hero.navigationAnimationType = .fade
        navigationController?.pushViewController(viewController, animated: true)
        return false
    }

}

// MARK: - EateryFilterViewControllerDelegate

extension HomeViewController: EateryFilterViewControllerDelegate {

    func eateryFilterViewController(_ viewController: EateryFilterViewController, filterDidChange filter: EateryFilter) {
        self.filter = filter
        applySnapshot()
    }
    
}
