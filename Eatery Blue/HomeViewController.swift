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

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let searchBar = UISearchBar()
    private let filtersView = PillFiltersView()
    private var carouselViews = [CarouselView]()
    private let allEateriesView = CardStackView()

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

            self.addFavoritesCarouselView()
            self.addAllEateriesView([DummyData.macs])
        }
    }

    private func setUpNavigation() {
        navigationController?.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "Home"),
            selectedImage: UIImage(named: "HomeSelected")
        )
        navigationController?.navigationBar.prefersLargeTitles = true

        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(named: "EateryBlue")
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        navigationController?.hero.isEnabled = true
        navigationController?.hero.navigationAnimationType = .fade

        navigationItem.title = "Eatery"
    }

    private func setUpView() {
        view.addSubview(scrollView)
        setUpScrollView()
    }

    private func setUpScrollView() {
        scrollView.alwaysBounceVertical = true
        scrollView.showsHorizontalScrollIndicator = false

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
            let viewController = PaymentMethodsFilterViewController()
            viewController.setUpSheetPresentation()
            present(viewController, animated: true)
        }
        filtersView.addButton(paymentMethods)
    }

    private func removeAllCarouselViews() {
        for view in carouselViews {
            view.removeFromSuperview()
        }

        carouselViews.removeAll()
    }

    private func addFavoritesCarouselView() {
        let carouselView = CarouselView()
        carouselView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        carouselView.scrollView.contentInset = carouselView.layoutMargins
        carouselView.titleLabel.text = "Favorite Eateries"

        for favorite in [DummyData.macs] {
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
                cardView.imageView.hero.id = "headerImageView"
                pushViewController(for: favorite)
            }

            carouselView.addCardView(cardView)
        }

        carouselViews.append(carouselView)
        stackView.addArrangedSubview(carouselView)
        stackView.setCustomSpacing(24, after: carouselView)
    }

    private func addAllEateriesView(_ eateries: [Eatery]) {
        allEateriesView.titleLabel.text = "All Eateries"
        allEateriesView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        for subview in allEateriesView.stackView.arrangedSubviews {
            subview.removeFromSuperview()
        }

        for eatery in eateries {
            let cardView = CardView()
            cardView.imageView.kf.setImage(with: eatery.imageUrl)
            cardView.titleLabel.text = eatery.name

            let subtitle = NSMutableAttributedString()
            subtitle.append(NSAttributedString(string: eatery.building ?? "--"))
            subtitle.append(NSAttributedString(string: " · "))
            subtitle.append(NSAttributedString(string: "Meal swipes allowed"))
            subtitle.append(NSAttributedString(string: "\n"))
            let watchImage = NSTextAttachment()
            watchImage.image = UIImage(named: "Watch")
            subtitle.append(NSAttributedString(attachment: watchImage))
            subtitle.append(NSAttributedString(string: "12 min walk"))
            subtitle.append(NSAttributedString(string: " · "))
            subtitle.append(NSAttributedString(string: "4-7 min wait"))
            cardView.subtitleLabel.attributedText = subtitle

            cardView.on(UITapGestureRecognizer()) { [self] _ in
                cardView.imageView.hero.id = "headerImageView"
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
    }

    private func pushViewController(for eatery: Eatery) {
        switch eatery {
        case let cafe as Cafe:
            let viewController = CafeViewController()
            viewController.setUp(cafe: cafe)
            navigationController?.pushViewController(viewController, animated: true)

        default:
            os_log(.error, "Unexpected eatery type %s", String(reflecting: eatery))
        }
    }

}

extension HomeViewController: UISearchBarDelegate {

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        let searchViewController = HomeSearchViewController()
        navigationController?.pushViewController(searchViewController, animated: true)

        return false
    }

}
