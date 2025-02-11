//
//  MenusViewController.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 1/12/25.
//  Originally Created by Antoinette Marie Torres on 9/13/23.
//

import EateryModel
import UIKit
import Combine

class MenusViewController: UIViewController {

    // MARK: - Properties (View)

    private let tableView = UITableView()
    private let navigationView = MenusNavigationView()

    // MARK: - Properties (Data)

    private var allEateries: [Int: [Eatery]] = [:]
    private var currentMealType: String = .Eatery.mealFromTime()
    private let daysToShow = 7
    private var expandedEateryIds: [Int64] = []
    private var filter = EateryFilter()
    private lazy var filterController = MenusFilterViewController(currentMealType: currentMealType)
    private var headerHeight: CGFloat = Constants.maxHeaderHeight
    private var isLoading = true
    private var previousScrollOffset: CGFloat = 0
    private var selectedIndex: Int = 0
    private var shownEateries: [Eatery] = []

    private lazy var dataSource = makeDataSource()

    struct Constants {
        static let minHeaderHeight: CGFloat = 44
        static let maxHeaderHeight: CGFloat = 98
        static let loadingHeaderHeight: CGFloat = maxHeaderHeight + 52
        static let tableViewTopPadding: CGFloat = 8
        static let tableViewYPadding: CGFloat = 16
        static let isTesting = false
    }

    // MARK: - Setup

    override func viewDidLoad() {
        super.viewDidLoad()

        RootViewController.setStatusBarStyle(.lightContent)

        view.addSubview(tableView)
        setUpTableView()

        view.addSubview(navigationView)
        setUpNavigationView()

        setUpConstraints()

        tableView.layoutIfNeeded()

        applySnapshot(animated: true)
        Task {
            startLoading()
            await updateAllEateriesFromNetworking(withPriority: selectedIndex)
            stopLoading()
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        tableView.contentInset.top = Constants.maxHeaderHeight + view.safeAreaInsets.top
        updateNavHeaderViewHeight()
    }

    private func setUpTableView() {
        tableView.backgroundColor = .Eatery.offWhite
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.delegate = self
        tableView.contentInset.bottom = tabBarController?.tabBar.frame.height ?? 0
        tableView.showsVerticalScrollIndicator = false
        tableView.alwaysBounceVertical = true
        tableView.alwaysBounceHorizontal = false
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 64

        tableView.register(MenuDayPickerTableViewCell.self, forCellReuseIdentifier: MenuDayPickerTableViewCell.reuse)
        tableView.register(MenuCardTableViewCell.self, forCellReuseIdentifier: MenuCardTableViewCell.reuse)
        tableView.register(ClearTableViewCell.self, forCellReuseIdentifier: ClearTableViewCell.reuse)

        setUpFilterController()
    }

    private func setUpNavigationView() {
        navigationView.logoRefreshControl.delegate = self
        navigationView.setFadeInProgress(0)
        navigationView.logoRefreshControl.addTarget(self, action: #selector(didRefresh), for: .valueChanged)
    }

    private func setUpFilterController() {
        addChild(filterController)

        filter.north = false
        filter.west = false
        filter.central = false

        filterController.delegate = self
        filterController.didMove(toParent: self)
    }

    private func setUpConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        navigationView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(view.safeAreaInsets.top)
        }
    }

    // MARK: - Actions

    func scrollToTop(animated: Bool) {
        tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
    }

    @objc private func didRefresh(_ sender: LogoRefreshControl) {

        Task {
            startLoading()
            await withThrowingTaskGroup(of: Void.self) { [weak self] group in
                guard let self else { return }
                group.addTask { [weak self] in
                    guard let self else { return }

                    await updateAllEateriesFromNetworking(withPriority: selectedIndex)
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

    /// Updates the provided day's eateries from networking first, and loads the others in the background
    private func updateAllEateriesFromNetworking(withPriority day: Int = 0) async {

        // Start Loading low priority days
        Task.detached(priority: .low) { [weak self] in
            guard let self else { return }

            await withTaskGroup(of: Void.self) { [weak self] group in
                guard let self else { return }

                for i in 0...(daysToShow - 1) {
                    i != day ? group.addTask { [weak self] in
                        guard let self else { return }

                        do {
                            try await updateAllEateriesByDayFromNetworking(i)
                            let loading = await isLoading
                            if await i == selectedIndex && loading { await stopLoading() }
                        } catch {
                            logger.error("\(#function): \(error)")
                        }
                    } : nil
                }
            }
        }

        // Load the high priority day
        do {
            try await updateAllEateriesByDayFromNetworking(day)
        } catch {
            logger.error("\(#function): \(error)")
        }
    }

    /// Load all of the eateries by the given index
    private func updateAllEateriesByDayFromNetworking(_ day: Int) async throws {
        let eateries = Constants.isTesting ? DummyData.eateries : try await Networking.default.loadEateryByDay(day: day)
        allEateries[day] = eateries
    }

    private func startLoading() {
        isLoading = true
        applySnapshot()
        view.isUserInteractionEnabled = false
    }

    private func stopLoading() {
        isLoading = false
        applySnapshot(animated: false)
        animateCellLoading()
        view.isUserInteractionEnabled = true
    }

    // MARK: - Utils

    /// Animate all of the cells loading in
    func animateCellLoading() {
        let collectionViewCells = tableView.visibleCells

        // only get the cells in the main section, in order
        let section = dataSource.index(for: .toolbar)
        // sort the cells by the section and then index
        let sortedCells = collectionViewCells.filter { section != tableView.indexPath(for: $0)!.section }.sorted { lhs, rhs in
            let lhsIdxPth = tableView.indexPath(for: lhs)!
            let rhsIdxPth = tableView.indexPath(for: rhs)!
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
            UIView.animate(withDuration: 1.2, delay: 0.1 * Double(delayCounter), usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
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

    // MARK: - Collection View Data Source

    /// Creates and returns the table view data source
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(tableView: tableView) { [weak self] (tableview, indexPath, item) in
            guard let self else { return UITableViewCell() }

            switch item {
            case .dayPicker(let days):
                guard let cell = tableview.dequeueReusableCell(withIdentifier: MenuDayPickerTableViewCell.reuse, for: indexPath) as? MenuDayPickerTableViewCell else { return UITableViewCell() }
                cell.updateDateDelegate = self
                cell.configure(days: days)
                cell.selectionStyle = .none
                return cell
            case .expandableCard(expandedEatery: let expandedEatery, allEateries: let allEateries):
                guard let cell = tableview.dequeueReusableCell(withIdentifier: MenuCardTableViewCell.reuse, for: indexPath) as? MenuCardTableViewCell else { return UITableViewCell() }
                cell.configure(expandedEatery: expandedEatery, allEateries: allEateries)
                cell.selectionStyle = .none
                return cell
            default:
                break
            }

            guard let cell = tableview.dequeueReusableCell(withIdentifier: ClearTableViewCell.reuse, for: indexPath) as? ClearTableViewCell else { return UITableViewCell() }

            switch item {
            case .customView(let view, _, _):
                let container = ContainerView(content: view)
                container.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
                cell.configure(content: container)
            case .titleLabel(title: let title):
                let label = UILabel()
                label.text = title
                label.font = .preferredFont(for: .title2, weight: .semibold)
                let container = ContainerView(content: label)
                container.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 8, right: 16)
                cell.configure(content: container)
            case .loadingLabel(title: let title):
                let label = UILabel()
                label.text = title
                label.textColor = UIColor.Eatery.gray02
                label.font = .preferredFont(for: .title2, weight: .semibold)
                let container = ContainerView(content: label)
                container.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 8, right: 16)
                cell.configure(content: container)
            case .loadingCard:
                let shimmerView = EateryCardShimmerView()
                let container = ContainerView(content: shimmerView)
                container.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
                cell.configure(content: container)
            default:
                break
            }

            cell.selectionStyle = .none
            return cell
        }

        return dataSource
    }

    /// Updates the table view data source, and animates if desired
    private func applySnapshot(animated: Bool = true) {
        var snapshot = Snapshot()

        let coreDataStack = AppDelegate.shared.coreDataStack
        let selectedDay = Day().advanced(by: selectedIndex)
        var days: [Day] = []
        for i in 0..<daysToShow {
            days.append(Day().advanced(by: i))
        }

        snapshot.appendSections([.toolbar])
        snapshot.appendItems([.dayPicker(days: days), .customView(view: filterController.view, height: 44)], toSection: .toolbar)

        snapshot.appendSections([.main])

        if isLoading {
            snapshot.appendItems([.loadingLabel(title: "Best in the biz since 2014...")], toSection: .main)
            for i in 0...5 {
                snapshot.appendItems([.loadingCard(index: i)], toSection: .main)
            }
        } else {
            let predicate = filter.predicate(userLocation: LocationManager.shared.userLocation, departureDate: Date())
            var filteredEateries = (allEateries[selectedIndex] ?? []).filter {
                predicate.isSatisfied(by: $0, metadata: coreDataStack.metadata(eateryId: $0.id))
            }

            // Only display eateries based on selected meal type

            // TODO: This should be an enum but good for now
            filteredEateries = filteredEateries.filter { eatery in
                if !eatery.paymentMethods.contains(.mealSwipes) { return false }

                let events = eatery.events.filter { $0.canonicalDay == Day().advanced(by: selectedIndex) }

                // Ignore Late Lunch
                if currentMealType == "Breakfast" {
                    return events.contains { $0.description == "Brunch" || $0.description == "Breakfast" }
                } else if currentMealType == "Lunch" {
                    return events.contains { $0.description == "Brunch" || $0.description == "Lunch" }
                } else if currentMealType == "Dinner" {
                    return events.contains { $0.description == "Dinner" }
                } else if currentMealType == "Late Dinner" {
                    return events.contains { $0.description == "Late Night" }
                }

                return false
            }

            var north: [Eatery] = []
            var west: [Eatery] = []
            var central: [Eatery] = []

            filteredEateries.forEach { eatery in
                if eatery.campusArea == "North" {
                    north.append(eatery)
                } else if eatery.campusArea == "West" {
                    west.append(eatery)
                } else if eatery.campusArea == "Central" {
                    central.append(eatery)
                }
            }

            if (filter.north || !filter.central && !filter.west && !filter.north) && north.count > 0 {
                snapshot.appendItems([.titleLabel(title: "North")], toSection: .main)
                north.forEach { eatery in
                    let expanded = expandedEateryIds.contains(eatery.id)
                    snapshot.appendItems([.expandableCard(expandedEatery: ExpandedEatery(eatery: eatery, selectedMealType: currentMealType, selectedDate: selectedDay, isExpanded: expanded), allEateries: allEateries[selectedIndex] ?? [])], toSection: .main)
                }
            }

            if (filter.west || !filter.central && !filter.west && !filter.north) && west.count > 0 {
                snapshot.appendItems([.titleLabel(title: "West")], toSection: .main)
                west.forEach { eatery in
                    let expanded = expandedEateryIds.contains(eatery.id)
                    snapshot.appendItems([.expandableCard(expandedEatery: ExpandedEatery(eatery: eatery, selectedMealType: currentMealType, selectedDate: selectedDay, isExpanded: expanded), allEateries: allEateries[selectedIndex] ?? [])], toSection: .main)
                }
            }

            if (filter.central || !filter.central && !filter.west && !filter.north) && central.count > 0 {
                snapshot.appendItems([.titleLabel(title: "Central")], toSection: .main)
                central.forEach { eatery in
                    let expanded = expandedEateryIds.contains(eatery.id)
                    snapshot.appendItems([.expandableCard(expandedEatery: ExpandedEatery(eatery: eatery, selectedMealType: currentMealType, selectedDate: selectedDay, isExpanded: expanded), allEateries: allEateries[selectedIndex] ?? [])], toSection: .main)
                }
            }

            if north.isEmpty && west.isEmpty && central.isEmpty {
                snapshot.appendItems([.titleLabel(title: "No eateries found...")], toSection: .main)
            }
        }

        dataSource.defaultRowAnimation = .fade
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

}

// MARK: - Table View Extensions

extension MenusViewController {

    typealias DataSource = UITableViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>


    enum Section {
        case toolbar
        case main
    }

    enum Item: Hashable {
        case dayPicker(days: [Day])
        case customView(view: UIView, height: CGFloat, padding: CGFloat = 0)
        case titleLabel(title: String)
        case loadingLabel(title: String)
        case expandableCard(expandedEatery: ExpandedEatery, allEateries: [Eatery])
        case loadingCard(index: Int)
    }

    struct ExpandedEatery: Hashable {
        let eatery: Eatery
        var selectedMealType: String?
        var selectedDate: Day?
        var isExpanded: Bool
    }


}

extension MenusViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return UITableView.automaticDimension }

        // there was some weirdness going on with the auto height for the day picker.
        switch item {
        case .dayPicker:
            return 80
        default:
            break
        }
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .expandableCard(expandedEatery: let expandedEatery, allEateries: _):
            let eatery = expandedEatery.eatery
            // if we are currently passed the end date of the event, do nothing
            var event: Event?
            // Ignoring Late Lunch
            if currentMealType == "Breakfast" {
                event = eatery.events.first { $0.description == "Brunch" || $0.description == "Breakfast" }
            } else if currentMealType == "Lunch" {
                event = eatery.events.first { $0.description == "Brunch" || $0.description == "Lunch"}
            } else if currentMealType == "Dinner" {
                event = eatery.events.first { $0.description == "Dinner" }
            } else if currentMealType == "Late Dinner" {
                event = eatery.events.first { $0.description == "Late Night" }
            }

            guard let event, event.endDate > Date() else { return }

            if expandedEateryIds.contains(expandedEatery.eatery.id) {
                expandedEateryIds.removeAll(where: { $0 == expandedEatery.eatery.id })
            } else {
                expandedEateryIds.append(expandedEatery.eatery.id)
            }

            applySnapshot()
        default:
            break
        }
    }

}

// MARK: - UIScrollViewDelegate

extension MenusViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        handleHeader(scrollView)
    }

    private func handleHeader(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y + scrollView.contentInset.top

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
            let refreshing = navigationView.logoRefreshControl.isRefreshing
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

extension MenusViewController: LogoRefreshControlDelegate {

    func logoRefreshControlDidBeginRefreshing(_ sender: LogoRefreshControl) {
        tableView.contentInset.top = Constants.loadingHeaderHeight + view.safeAreaInsets.top
    }

    func logoRefreshControlDidEndRefreshing(_ sender: LogoRefreshControl) {
        headerHeight = Constants.maxHeaderHeight
        updateNavHeaderViewHeight()
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self else { return }

            tableView.contentInset.top = Constants.maxHeaderHeight + view.safeAreaInsets.top
            view.layoutIfNeeded()
        }

        navigationView.logoRefreshControl.setPullProgress(0)
    }

}

// MARK: - EateryFilterViewControllerDelegate

extension MenusViewController: MenusFilterViewControllerDelegate {

    func menusFilterViewController(_ viewController: MenusFilterViewController, didChangeLocation filter: EateryFilter) {
        self.filter = filter
        applySnapshot()
    }

    func menusFilterViewController(_ viewController: MenusFilterViewController, didChangeMenuType string: String) {
        currentMealType = string
        applySnapshot()

        if currentMealType == "Breakfast" {
            filterController.selectedMenuIndex = 0
        } else if currentMealType == "Lunch" {
            filterController.selectedMenuIndex = 1
        } else if currentMealType == "Dinner" {
            filterController.selectedMenuIndex = 2
        } else if currentMealType == "Late Dinner" {
            filterController.selectedMenuIndex = 3
        }
    }
    
}

// MARK: - UpdateDateDelegate

extension MenusViewController: UpdateDateDelegate {

    func updateMenuDay(index: Int) {
        selectedIndex = index
        expandedEateryIds = []

        if allEateries[selectedIndex] == nil {
            startLoading()
        } else {
            stopLoading()
        }
    }

}

