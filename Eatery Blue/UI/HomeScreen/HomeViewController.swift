//
//  HomeViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import Combine
import CoreLocation
import EateryModel
import UIKit
import Kingfisher

class HomeViewController: UIViewController {

    enum Cell {
        case searchBar
        case customView(view: UIView)
        case carouselView(CarouselView)
        case loadingView(CarouselView)
        case titleLabel(title: String)
        case loadingLabel(title: String)
        case eateryCard(eatery: Eatery)
        case loadingCard
    }
    
    private struct Constants {
        static let searchBarLayoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        static let carouselViewLayoutMargins = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        static let labelLayoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 8, right: 16)
        static let cardViewLayoutMargins = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        static let customViewLayoutMargins = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
    }

    let navigationView = HomeNavigationView()
    private let tableView = UITableView()
    private let tableHeaderView = UIView()

    private(set) var cells: [Cell] = []
    private(set) var eateries: [Eatery] = []
    private(set) var extraIndex: Int = 0
    private lazy var setLoadingInset: Void = {
        scrollToTop(animated: false)
    }()
    private var hasLoadedMenuData: Bool = false

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        setUpView()
        setUpConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        RootViewController.setStatusBarStyle(.lightContent)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateScrollViewContentInset()
        _ = setLoadingInset
    }

    private func setUpView() {
        view.addSubview(tableView)
        setUpTableView()

        view.addSubview(navigationView)
        setUpNavigationView()
    }

    private func setUpTableView() {
        tableView.isScrollEnabled = true
        tableView.showsVerticalScrollIndicator = false
        tableView.alwaysBounceVertical = true
        tableView.showsHorizontalScrollIndicator = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 216
        tableView.tableHeaderView = tableHeaderView
        tableView.tableFooterView = UIView()
    }

    private func setUpNavigationView() {
        navigationView.logoRefreshControl.delegate = self
        navigationView.setFadeInProgress(0)
    }

    private func setUpConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        navigationView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(tableHeaderView.snp.top).priority(.low)
            make.bottom.greaterThanOrEqualTo(tableHeaderView.snp.top)
        }
    }

    func pushViewController(eateryIndex: Int) {
        let pageVC = EateryPageViewController(eateries: eateries, index: eateryIndex)
        navigationController?.hero.isEnabled = true
        navigationController?.heroNavigationAnimationType = .fade
        navigationController?.pushViewController(pageVC, animated: true)
    }

    private func updateScrollViewContentInset() {
        var top = navigationView.computeExpandedHeight()

        if navigationView.logoRefreshControl.isRefreshing {
            top += 44
        }

        tableView.contentInset.top = top
        tableView.contentInset.bottom = view.safeAreaInsets.bottom
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        updateScrollViewContentInset()
    }

    func scrollToTop(animated: Bool) {
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: animated)
    }
    
    func animateCellLoading() {
        let tableViewCells = tableView.visibleCells
        var delayCounter = 0
        
        tableViewCells.forEach { cell in
            cell.transform = CGAffineTransform(translationX: 0, y: 82)
            cell.alpha = 0
        }
        
        for index in 0..<tableViewCells.count {
            switch cells[index] {
            case .carouselView:
                UIView.animate(withDuration: 1.2, delay: 0.2 * Double(delayCounter),usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                    tableViewCells[index].transform = CGAffineTransform.identity
                    tableViewCells[index].alpha = 1
                }, completion: nil)
                delayCounter += 1
            case .titleLabel:
                UIView.animate(withDuration: 1.2, delay: 0.2 * Double(delayCounter),usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                    tableViewCells[index].transform = CGAffineTransform.identity
                    tableViewCells[index].alpha = 1
                }, completion: nil)
                delayCounter += 1
            case .eateryCard:
                UIView.animate(withDuration: 1.2, delay: 0.2 * Double(delayCounter),usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                    tableViewCells[index].transform = CGAffineTransform.identity
                    tableViewCells[index].alpha = 1
                }, completion: nil)
                delayCounter += 1
            default:
                tableViewCells[index].transform = CGAffineTransform.identity
                tableViewCells[index].alpha = 1
            }
        }
    }

}

extension HomeViewController: UISearchBarDelegate {

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        let viewController = HomeSearchModelController()
        navigationController?.hero.isEnabled = true
        navigationController?.hero.navigationAnimationType = .fade
        navigationController?.pushViewController(viewController, animated: true)
        return false
    }

}

extension HomeViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cells.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = cells[indexPath.row]
        switch cellType {
        case .searchBar:
            let searchBar = UISearchBar()
            searchBar.delegate = self
            searchBar.placeholder = "Search for grub..."
            searchBar.layoutMargins = Constants.searchBarLayoutMargins
            searchBar.backgroundImage = UIImage()
            searchBar.hero.id = "searchBar"

            let cell = ClearTableViewCell(content: searchBar)
            cell.selectionStyle = .none
            return cell
        case .customView(let view):
            let container = ContainerView(content: view)
            container.layoutMargins = Constants.customViewLayoutMargins

            let cell = ClearTableViewCell(content: container)
            cell.selectionStyle = .none
            return cell
        case .titleLabel(title: let title):
            let label = UILabel()
            label.text = title
            label.font = .preferredFont(for: .title2, weight: .semibold)

            let container = ContainerView(content: label)
            container.layoutMargins = Constants.labelLayoutMargins

            let cell = ClearTableViewCell(content: container)
            cell.selectionStyle = .none
            return cell
        case .loadingLabel(title: let title):
            let label = UILabel()
            label.text = title
            label.textColor = UIColor.Eatery.gray02
            label.font = .preferredFont(for: .title2, weight: .semibold)

            let container = ContainerView(content: label)
            container.layoutMargins = Constants.labelLayoutMargins

            let cell = ClearTableViewCell(content: container)
            cell.selectionStyle = .none
            return cell
        case .loadingView(let carouselView):
            let container = ContainerView(content: carouselView)
            container.layoutMargins = Constants.carouselViewLayoutMargins

            let cell = ClearTableViewCell(content: container)
            cell.selectionStyle = .none
            return cell
        case .carouselView(let carouselView):
            let container = ContainerView(content: carouselView)
            container.layoutMargins = Constants.carouselViewLayoutMargins

            let cell = ClearTableViewCell(content: container)
            cell.selectionStyle = .none
            return cell
        case .loadingCard:
            let contentView = EateryLargeLoadingCardView()

            let cardView = EateryCardVisualEffectView(content: contentView)
            cardView.layoutMargins = Constants.cardViewLayoutMargins

            let cell = ClearTableViewCell(content: cardView)
            cell.selectionStyle = .none
            return cell
        case .eateryCard(eatery: let eatery):
            let contentView = EateryLargeCardContentView()
            contentView.imageView.image = UIImage()
            contentView.imageView.kf.setImage(with: eatery.imageUrl)
            contentView.imageTintView.alpha = eatery.isOpen ? 0 : 0.5
            contentView.titleLabel.text = eatery.name
            contentView.imageView.hero.id = eatery.imageUrl?.absoluteString

            let metadata = AppDelegate.shared.coreDataStack.metadata(eateryId: eatery.id)
            if metadata.isFavorite {
                contentView.favoriteImageView.image = UIImage(named: "FavoriteSelected")
            } else {
                contentView.favoriteImageView.image = UIImage(named: "FavoriteUnselected")
            }

            contentView.subtitleLabels[0].text = eatery.locationDescription
            contentView.subtitleLabels[1].attributedText = EateryFormatter.default.eateryCardFormatter(eatery, date: Date())

            let now = Date()
            switch eatery.status {
            case .closingSoon(let event):
                let alert = EateryCardAlertView()
                let minutesUntilClosed = Int(round(event.endDate.timeIntervalSince(now) / 60))
                alert.titleLabel.text = "Closing in \(minutesUntilClosed) min"
                contentView.addAlertView(alert)

            case .openingSoon(let event):
                let alert = EateryCardAlertView()
                let minutesUntilOpen = Int(round(event.startDate.timeIntervalSince(now) / 60))
                alert.titleLabel.text = "Opening in \(minutesUntilOpen) min"
                contentView.addAlertView(alert)

            default:
                break
            }

            let cardView = EateryCardVisualEffectView(content: contentView)
            cardView.layoutMargins = Constants.cardViewLayoutMargins

            let cell = ClearTableViewCell(content: cardView)
            cell.selectionStyle = .none
            return cell
        }
    }

    func updateCells(cells: [Cell], allEateries: [Eatery], eateryStartIndex: Int) {
        self.cells = cells
        self.eateries = allEateries
        self.extraIndex = eateryStartIndex
        tableView.reloadData()
    }

}

extension HomeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        switch cells[indexPath.row] {
        case .eateryCard:
            let cell = tableView.cellForRow(at: indexPath)
            UIView.animate(withDuration: 0.15, delay: 0, options: .beginFromCurrentState) {
                cell?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }

        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        switch cells[indexPath.row] {
        case .eateryCard:
            let cell = tableView.cellForRow(at: indexPath)
            UIView.animate(withDuration: 0.15, delay: 0, options: .beginFromCurrentState) {
                cell?.transform = .identity
            }

        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch cells[indexPath.row] {
        case .eateryCard:
            pushViewController(eateryIndex: indexPath.row - self.extraIndex)

        default:
            break
        }
    }

}

extension HomeViewController: UIScrollViewDelegate {

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        // It's important that handleSnapping is called after handlePullToRefresh since handlePullToRefresh may update
        // contentInset which handleSnapping depends on
        handlePullToRefresh(scrollView)
        handleSnapping(scrollView, velocity: velocity, targetContentOffset: targetContentOffset)
    }

    private func handleSnapping(_ scrollView: UIScrollView, velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let superview = scrollView.superview else {
            return
        }

        let currentPosition = scrollView.contentOffset.y
        let decelerationRate = scrollView.decelerationRate.rawValue
        var finalPosition = currentPosition + velocity.y * decelerationRate / (1 - decelerationRate)
        let navigationBarNormalPosition = -superview.convert(
            CGPoint(x: 0, y: navigationView.computeNormalHeight()),
            from: navigationView
        ).y
        let navigationBarExpandedPosition = -superview.convert(
            CGPoint(x: 0, y: navigationView.computeExpandedHeight()),
            from: navigationView
        ).y

        if navigationBarExpandedPosition <= finalPosition && finalPosition <= navigationBarNormalPosition {
            // Snap to the expanded position or normal position, whichever is closer
            let distanceToExpandedPosition = abs(finalPosition - navigationBarExpandedPosition)
            let distanceToNormalPosition = abs(finalPosition - navigationBarNormalPosition)

            if distanceToExpandedPosition < distanceToNormalPosition {
                finalPosition = navigationBarExpandedPosition
            } else {
                finalPosition = navigationBarNormalPosition
            }
        }

        targetContentOffset.pointee = CGPoint(x: 0, y: finalPosition)
    }

    private func handlePullToRefresh(_ scrollView: UIScrollView) {
        let deltaFromTop = tableView.contentOffset.y + tableView.contentInset.top
        let pullProgress = (-deltaFromTop - 22) / 66

        if pullProgress > 1.1 {
            navigationView.logoRefreshControl.beginRefreshing()
            updateScrollViewContentInset()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        handleNavigationView()
    }

    private func handleNavigationView() {
        guard let superview = tableView.superview else {
            return
        }

        // Handle normal navigation bar

        let currentPosition = tableView.contentOffset.y
        let navigationBarNormalPosition = -superview.convert(
            CGPoint(x: 0, y: navigationView.computeNormalHeight()),
            from: navigationView
        ).y

        // If the current position is about to eclipse the navigation bar normal position, fade in the normal bar
        if currentPosition > navigationBarNormalPosition - 16 {
            navigationView.setFadeInProgress(1, animated: true)
        } else {
            navigationView.setFadeInProgress(0, animated: true)
        }

        // Handle logo refresh control and large title label

        let deltaFromTop = tableView.contentOffset.y + tableView.contentInset.top

        if !navigationView.logoRefreshControl.isRefreshing {
            let pullProgress = (-deltaFromTop - 22) / 66
            navigationView.logoRefreshControl.setPullProgress(pullProgress)
        }

        let fadeDistance = navigationView.logoRefreshControl.bounds.height
        let progress = max(0, min(1, 1 - deltaFromTop / fadeDistance))
        navigationView.logoRefreshControl.alpha = progress
        navigationView.largeTitleLabel.alpha = progress
    }

}

extension HomeViewController: LogoRefreshControlDelegate {

    func logoRefreshControlDidBeginRefreshing(_ sender: LogoRefreshControl) {
    }

    func logoRefreshControlDidEndRefreshing(_ sender: LogoRefreshControl) {
        UIView.animate(withDuration: 0.15) { [self] in
            updateScrollViewContentInset()
        }
    }

}
