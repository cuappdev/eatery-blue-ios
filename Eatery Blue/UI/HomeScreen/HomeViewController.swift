//
//  HomeViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import Combine
import CoreLocation
import UIKit
import Kingfisher

class HomeViewController: UIViewController {

    struct EateryCollection: Hashable {
        var title: String
        var description: String?
        var eateries: [Eatery]
    }

    enum Cell: Hashable {
        case searchBar
        case customView(view: UIView)
        case carouselView(collection: EateryCollection)
        case titleLabel(title: String)
        case eateryCard(eatery: Eatery)
    }

    let navigationView = HomeNavigationView()
    let tableView = UITableView()
    private let tableHeaderView = UIView()

    var cells: [Cell] = []
    @Published var userLocation: CLLocation? = nil

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
    }

    private func setUpView() {
        view.addSubview(tableView)
        setUpTableView()

        view.addSubview(navigationView)
        setUpNavigationView()
    }

    private func setUpTableView() {
        tableView.showsVerticalScrollIndicator = false
        tableView.alwaysBounceVertical = true
        tableView.showsHorizontalScrollIndicator = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 216
        tableView.allowsSelection = false
        tableView.tableHeaderView = tableHeaderView
        tableView.tableFooterView = UIView()

        tableView.register(CarouselTableViewCell.self, forCellReuseIdentifier: "carouselView")
        tableView.register(EateryLargeCardTableViewCell.self, forCellReuseIdentifier: "eateryCard")
    }

    private func setUpNavigationView() {
        navigationView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 8, right: 16)
        navigationView.logoRefreshControl.delegate = self
    }

    private func setUpConstraints() {
        tableView.edgesToSuperview()

        navigationView.edgesToSuperview(excluding: .bottom)

        navigationView.bottomToTop(of: tableHeaderView, priority: .defaultLow)
        navigationView.bottomToTop(of: tableHeaderView, relation: .equalOrGreater)
    }

    func pushViewController(for eatery: Eatery) {
        let viewController = EateryModelController()
        viewController.setUp(eatery: eatery)
        navigationController?.hero.isEnabled = false
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func updateScrollViewContentInset() {
        var top = navigationView.computeFullyExpandedHeight()

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

}

extension HomeViewController: UISearchBarDelegate {

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
            searchBar.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            searchBar.backgroundImage = UIImage()
            searchBar.hero.id = "searchBar"

            let cell = ClearTableViewCell()
            cell.contentView.addSubview(searchBar)
            searchBar.edgesToSuperview()
            return cell

        case .customView(let view):
            let cell = ClearTableViewCell()
            cell.contentView.addSubview(view)
            view.edgesToSuperview(insets: UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0))
            return cell

        case .titleLabel(title: let title):
            let label = UILabel()
            label.text = title
            label.font = .preferredFont(for: .title2, weight: .semibold)

            let container = ContainerView(content: label)
            container.layoutMargins = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)

            let cell = ClearTableViewCell()
            cell.contentView.addSubview(container)
            container.edgesToSuperview()
            return cell

        case .carouselView(collection: let collection):
            let carouselView = CarouselView()
            carouselView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            carouselView.scrollView.contentInset = carouselView.layoutMargins
            carouselView.titleLabel.text = collection.title

            for eatery in collection.eateries.prefix(3) {
                let cardView = EateryMediumCardView()
                cardView.imageView.kf.setImage(
                    with: eatery.imageUrl,
                    options: [
                        .backgroundDecode
                    ]
                )
                cardView.imageTintView.alpha = EateryStatus(eatery.events).isOpen ? 0 : 0.5
                cardView.titleLabel.text = eatery.name

                $userLocation
                    .sink { userLocation in
                        cardView.subtitleLabel.attributedText = EateryFormatter.default.formatEatery(
                            eatery,
                            style: .medium,
                            font: .preferredFont(for: .footnote, weight: .medium),
                            userLocation: userLocation,
                            date: Date()
                        ).first
                    }
                    .store(in: &cancellables)

                cardView.on(UITapGestureRecognizer()) { [self] _ in
                    pushViewController(for: eatery)
                }

                carouselView.addCardView(cardView)
            }

            if collection.eateries.count > 3 {
                let view = CarouselMoreEateriesView()
                view.on(UITapGestureRecognizer()) { [self] _ in
                    didTapMoreButton(collection)
                }
                carouselView.addAccessoryView(view)
            }

            carouselView.buttonImageView.on(UITapGestureRecognizer()) { [self] _ in
                didTapMoreButton(collection)
            }

            let cell = ClearTableViewCell()
            cell.contentView.addSubview(carouselView)
            cell.contentView.clipsToBounds = false
            cell.contentView.backgroundColor = nil
            cell.backgroundView = UIView()
            cell.backgroundView?.backgroundColor = nil
            cell.backgroundColor = nil
            cell.clipsToBounds = false
            carouselView.edgesToSuperview(insets: UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0))
            return cell

        case .eateryCard(eatery: let eatery):
            let cardView = EateryLargeCardView()
            cardView.imageView.kf.setImage(
                with: eatery.imageUrl,
                options: [
                    .backgroundDecode
                ]
            )
            cardView.imageTintView.alpha = EateryStatus(eatery.events).isOpen ? 0 : 0.5
            cardView.titleLabel.text = eatery.name

            $userLocation
                .sink { userLocation in
                    let lines = EateryFormatter.default.formatEatery(
                        eatery,
                        style: .long,
                        font: .preferredFont(for: .footnote, weight: .medium),
                        userLocation: userLocation,
                        date: Date()
                    )

                    for (i, subtitleLabel) in cardView.subtitleLabels.enumerated() {
                        if i < lines.count {
                            subtitleLabel.attributedText = lines[i]
                        } else {
                            subtitleLabel.isHidden = true
                        }
                    }
                }
                .store(in: &cancellables)

            cardView.on(UITapGestureRecognizer()) { [self] _ in
                pushViewController(for: eatery)
            }

            cardView.height(216)

            let cell = EateryLargeCardTableViewCell(cardView: cardView)
            cell.cell.layoutMargins = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
            return cell
        }
    }

    private func didTapMoreButton(_ collection: EateryCollection) {
        let viewController = ListModelController()
        viewController.setUp(
            collection.eateries,
            title: collection.title,
            description: collection.description
        )

        navigationController?.hero.isEnabled = false
        navigationController?.pushViewController(viewController, animated: true)
    }

}

extension HomeViewController: UITableViewDelegate {

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
            CGPoint(x: 0, y: navigationView.computeFullyExpandedHeight()),
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
        handleLogo()
    }

    private func handleNavigationView() {
        guard let superview = tableView.superview else {
            return
        }

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
    }

    private func handleLogo() {
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
