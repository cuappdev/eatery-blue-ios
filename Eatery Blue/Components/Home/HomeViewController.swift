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

    private let navigationView = HomeNavigationView()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let searchBar = UISearchBar()
    private let filtersView = PillFiltersView()
    private var carouselViews = [CarouselView]()
    private let allEateriesView = EateryCardStackView()

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

        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.removeAllCarouselViews()
            self.allEateriesView.removeFromSuperview()

            self.addFavoritesCarouselView(favorites: [
                DummyData.rpcc, DummyData.macs
            ])
            self.addAllEateriesView([
                DummyData.macs,
                DummyData.macsClosed,
                DummyData.macsOpenSoon,
                DummyData.macsClosingSoon
            ])
        }

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
        view.addSubview(scrollView)
        setUpScrollView()

        view.addSubview(navigationView)
        setUpNavigationView()
    }

    private func setUpScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self

        scrollView.addSubview(stackView)
        setUpStackView()
    }

    private func setUpStackView() {
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill

        stackView.spacing = 12

        stackView.addArrangedSubview(searchBar)
        // Deal with UISearchBar's permanent 8px spacing
        stackView.setCustomSpacing(4, after: searchBar)
        setUpSearchBar()

        stackView.addArrangedSubview(filtersView)
        setUpFiltersView()
    }

    private func setUpSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search for grub..."
        searchBar.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        searchBar.backgroundImage = UIImage()
        searchBar.hero.id = "searchBar"
    }

    private func setUpFiltersView() {
        filtersView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let shortFilter = PillFilterButtonView()
        shortFilter.label.text = "Under 10 min"
        shortFilter.on(UITapGestureRecognizer()) { [weak shortFilter] _ in
            guard let shortFilter = shortFilter else { return }
            shortFilter.setHighlighted(!shortFilter.isHighlighted)
        }
        filtersView.addButton(shortFilter)

        let paymentMethods = PillFilterButtonView()
        paymentMethods.label.text = "Payment Methods"
        paymentMethods.imageView.isHidden = false
        paymentMethods.on(UITapGestureRecognizer()) { [self] _ in
            let viewController = PaymentMethodsFilterSheetViewController()
            viewController.setUpSheetPresentation()
            present(viewController, animated: true)
        }
        filtersView.addButton(paymentMethods)
    }

    private func setUpNavigationView() {
        navigationView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 8, right: 16)

        navigationView.searchButton.on(UITapGestureRecognizer()) { [self] _ in
            let searchViewController = HomeSearchViewController()
            navigationController?.hero.isEnabled = false
            navigationController?.pushViewController(searchViewController, animated: true)
        }

        navigationView.bottomToTop(of: stackView, priority: .defaultLow)
        navigationView.bottomToTop(of: stackView, relation: .equalOrGreater)
    }

    private func removeAllCarouselViews() {
        for view in carouselViews {
            view.removeFromSuperview()
        }

        carouselViews.removeAll()
    }

    private func addFavoritesCarouselView(favorites: [Eatery]) {
        let carouselView = CarouselView()
        carouselView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        carouselView.scrollView.contentInset = carouselView.layoutMargins
        carouselView.titleLabel.text = "Favorite Eateries"

        for favorite in favorites {
            let cardView = CarouselCardView()
            cardView.imageView.kf.setImage(
                with: favorite.imageUrl,
                options: [
                    .processor(DownsamplingImageProcessor(size: CGSize(width: 343, height: 127))),
                    .scaleFactor(UIScreen.main.scale),
                    .cacheOriginalImage
                ]
            )
            cardView.titleLabel.text = favorite.name
            cardView.subtitleLabel.text = """
            \(favorite.building ?? "--") · \(favorite.menuSummary ?? "--")
            """

            cardView.on(UITapGestureRecognizer()) { [self] _ in
                pushViewController(for: favorite)
            }

            carouselView.addCardView(cardView)
        }

        carouselViews.append(carouselView)
        stackView.addArrangedSubview(carouselView)
        stackView.setCustomSpacing(24, after: carouselView)

        carouselView.buttonImageView.on(UITapGestureRecognizer()) { [self] _ in
            let viewController = ListViewController()
            viewController.setUp(
                favorites,
                title: "Favorite Eateries"
            )

            navigationController?.hero.isEnabled = false
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

    private func addAllEateriesView(_ eateries: [Eatery]) {
        allEateriesView.titleLabel.text = "All Eateries"
        allEateriesView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        for subview in allEateriesView.stackView.arrangedSubviews {
            subview.removeFromSuperview()
        }

        for eatery in eateries {
            let cardView = EateryCardView()
            cardView.imageView.kf.setImage(with: eatery.imageUrl)
            cardView.titleLabel.text = eatery.name

            cardView.subtitleLabel1.attributedText = EateryFormatter.default.formatEatery(
                eatery,
                font: cardView.subtitleLabel1.font
            )

            cardView.subtitleLabel2.attributedText = EateryFormatter.default.formatTimingInfo(
                eatery,
                font: cardView.subtitleLabel1.font
            )

            cardView.on(UITapGestureRecognizer()) { [self] _ in
                pushViewController(for: eatery)
            }

            allEateriesView.addCardView(cardView)
        }

        stackView.addArrangedSubview(allEateriesView)
    }

    private func setUpConstraints() {
        scrollView.edgesToSuperview()

        stackView.edgesToSuperview()
        stackView.width(to: view)

        navigationView.edgesToSuperview(excluding: .bottom)
    }

    private func pushViewController(for eatery: Eatery) {
        switch eatery {
        case let cafe as Cafe:
            let viewController = CafeViewController()
            viewController.setUp(cafe: cafe)
            navigationController?.hero.isEnabled = false
            navigationController?.pushViewController(viewController, animated: true)

        case let diningHall as DiningHall:
            let viewController = DiningHallViewController()
            viewController.setUp(diningHall: diningHall)
            navigationController?.hero.isEnabled = false
            navigationController?.pushViewController(viewController, animated: true)

        default:
            os_log(.error, "Unexpected eatery type %s", String(reflecting: eatery))
        }
    }

    private func updateScrollViewContentInset() {
        scrollView.contentInset.top = navigationView.computeFullyExpandedHeight()
        scrollView.contentInset.bottom = view.safeAreaInsets.bottom
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
        guard let superview = scrollView.superview else {
            return
        }

        let currentPosition = scrollView.contentOffset.y
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
        let deltaFromTop = scrollView.contentOffset.y + scrollView.contentInset.top
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
