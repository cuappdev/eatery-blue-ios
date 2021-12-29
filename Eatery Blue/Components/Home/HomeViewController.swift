//
//  HomeViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import os.log
import UIKit
import Kingfisher

class HomeViewController: UIViewController {

    struct EateryCollection {
        var title: String
        var description: String?
        var eateries: [Eatery]
    }

    enum Cell {
        case searchBar
        case filterView(buttons: [PillFilterButtonView])
        case carouselView(collection: EateryCollection)
        case titleLabel(title: String)
        case eateryCard(eatery: Eatery)
    }

    let navigationView = HomeNavigationView()
    let tableView = UITableView()
    private let tableHeaderView = UIView()

    var cells: [Cell] = []

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        setUpNavigation()
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

    private func setUpNavigation() {
        navigationController?.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "Home"),
            selectedImage: UIImage(named: "HomeSelected")
        )
        navigationController?.setNavigationBarHidden(true, animated: false)
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
        tableView.estimatedRowHeight = 44

        tableView.tableHeaderView = tableHeaderView
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false

        tableView.register(CarouselTableViewCell.self, forCellReuseIdentifier: "carouselView")
        tableView.register(EateryCardTableViewCell.self, forCellReuseIdentifier: "eateryCard")
    }

    private func setUpNavigationView() {
        navigationView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 8, right: 16)

        navigationView.searchButton.on(UITapGestureRecognizer()) { [self] _ in
            let searchViewController = HomeSearchViewController()
            navigationController?.hero.isEnabled = false
            navigationController?.pushViewController(searchViewController, animated: true)
        }

        navigationView.bottomToTop(of: tableHeaderView, priority: .defaultLow)
        navigationView.bottomToTop(of: tableHeaderView, relation: .equalOrGreater)
    }

    private func setUpConstraints() {
        tableView.edgesToSuperview()

        navigationView.edgesToSuperview(excluding: .bottom)
    }

    func pushViewController(for eatery: Eatery) {
        let viewController = EateryModelController()
        viewController.setUp(eatery: eatery)
        navigationController?.hero.isEnabled = false
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func updateScrollViewContentInset() {
        tableView.contentInset.top = navigationView.computeFullyExpandedHeight()
        tableView.contentInset.bottom = view.safeAreaInsets.bottom
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        updateScrollViewContentInset()
    }

}

extension HomeViewController: UISearchBarDelegate {

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        let searchViewController = HomeSearchViewController()
        navigationController?.hero.isEnabled = true
        navigationController?.hero.navigationAnimationType = .fade
        navigationController?.pushViewController(searchViewController, animated: true)
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
            searchBar.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            searchBar.backgroundImage = UIImage()
            searchBar.hero.id = "searchBar"

            let cell = ClearTableViewCell()
            cell.contentView.addSubview(searchBar)
            searchBar.edgesToSuperview()
            return cell

        case .filterView(buttons: let filterButtons):
            let filtersView = PillFiltersView()
            filtersView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

            for filterButton in filterButtons {
                filtersView.addButton(filterButton)
            }

            let cell = ClearTableViewCell()
            cell.contentView.addSubview(filtersView)
            filtersView.edgesToSuperview(insets: UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0))
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

            for eatery in collection.eateries {
                let cardView = CarouselCardView()
                cardView.imageView.kf.setImage(
                    with: eatery.imageUrl,
                    options: [
                        .backgroundDecode
                    ]
                )
                cardView.titleLabel.text = eatery.name
                cardView.subtitleLabel.text = """
                \(eatery.building ?? "--") · \(eatery.menuSummary ?? "--")
                """

                cardView.on(UITapGestureRecognizer()) { [self] _ in
                    pushViewController(for: eatery)
                }

                carouselView.addCardView(cardView)
            }

            carouselView.buttonImageView.on(UITapGestureRecognizer()) { [self] _ in
                let viewController = ListViewController()
                viewController.setUp(
                    collection.eateries,
                    title: collection.title,
                    description: collection.description
                )

                navigationController?.hero.isEnabled = false
                navigationController?.pushViewController(viewController, animated: true)
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
            let cardView = EateryCardView()
            cardView.imageView.kf.setImage(
                with: eatery.imageUrl,
                options: [
                    .backgroundDecode
                ]
            )
            cardView.titleLabel.text = eatery.name
            cardView.subtitleLabel1.attributedText = EateryFormatter.default.formatEatery(
                eatery,
                font: cardView.subtitleLabel1.font
            )
            cardView.subtitleLabel2.attributedText = EateryFormatter.default.formatTimingInfo(
                eatery,
                font: cardView.subtitleLabel2.font
            )

            cardView.on(UITapGestureRecognizer()) { [self] _ in
                pushViewController(for: eatery)
            }

            cardView.height(216)

            let cell = EateryCardTableViewCell(cardView: cardView)
            cell.cell.layoutMargins = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
            return cell
        }
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
        let fadeDistance = 44.0
        let transform = CGAffineTransform(
            translationX: 0,
            y: max(-fadeDistance, -deltaFromTop)
        )
        navigationView.logoView.transform = transform

        let progress = max(0, min(1, 1 - deltaFromTop / fadeDistance))
        navigationView.logoView.alpha = progress
        navigationView.largeTitleLabel.alpha = progress
    }

}
