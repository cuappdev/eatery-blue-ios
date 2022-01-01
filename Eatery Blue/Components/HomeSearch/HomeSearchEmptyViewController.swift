//
//  HomeSearchEmptyViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/1/22.
//

import UIKit

class HomeSearchEmptyViewController: UIViewController {

    enum RecentSearchType: String, Codable {
        case item
        case place
    }

    struct RecentSearch: Codable, Hashable {
        let type: RecentSearchType
        let title: String
        let subtitle: String?
    }

    let blurView = UIVisualEffectView()
    let separator = HDivider()

    let scrollView = UIScrollView()
    let stackView = UIStackView()
    let favoritesView = CarouselViewCompact()
    let recentsView = SearchRecentsView()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        setUpConstraints()
    }

    private func setUpView() {
        view.backgroundColor = .white

        view.addSubview(scrollView)
        setUpScrollView()

        view.addSubview(blurView)
        setUpBlurView()

        view.addSubview(separator)
    }

    private func setUpScrollView() {
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self

        scrollView.addSubview(stackView)
        setUpStackView()
    }

    private func setUpStackView() {
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 24

        stackView.addArrangedSubview(favoritesView)
        setUpFavoritesView()

        stackView.addArrangedSubview(recentsView)
        setUpRecentsView()
    }

    private func setUpFavoritesView() {
        favoritesView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        favoritesView.scrollView.contentInset = favoritesView.layoutMargins
        favoritesView.titleLabel.text = "Favorites"
    }

    private func setUpRecentsView() {
        recentsView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }

    private func setUpBlurView() {
        blurView.effect = UIBlurEffect(style: .prominent)
    }

    private func setUpConstraints() {
        scrollView.edgesToSuperview()

        stackView.edgesToSuperview()
        stackView.widthToSuperview()

        blurView.edgesToSuperview(excluding: .bottom)
        blurView.bottomToTop(of: view.safeAreaLayoutGuide)

        separator.bottomToTop(of: view.safeAreaLayoutGuide)
    }

    func updateFavorites(_ favorites: [Eatery]) {
        favoritesView.removeAllCardViews()

        for favorite in favorites {
            let cardView = EaterySmallCardView()
            cardView.imageView.kf.setImage(with: favorite.imageUrl)
            cardView.titleLabel.text = favorite.name
            favoritesView.addCardView(cardView)
        }
    }

    func updateRecentSearches(_ recentSearches: [RecentSearch]) {
        recentsView.removeAllItems()

        for recentSearch in recentSearches {
            let itemView = SearchRecentItemView()
            itemView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            switch recentSearch.type {
            case .item:
                itemView.imageView.image = UIImage(named: "Item")?.withRenderingMode(.alwaysTemplate)
            case .place:
                itemView.imageView.image = UIImage(named: "Place")?.withRenderingMode(.alwaysTemplate)
            }
            itemView.imageView.tintColor = UIColor(named: "EateryBlue")
            itemView.titleLabel.text = recentSearch.title

            if let subtitle = recentSearch.subtitle {
                itemView.subtitleLabel.isHidden = false
                itemView.subtitleLabel.text = subtitle
            } else {
                itemView.subtitleLabel.isHidden = true
            }

            recentsView.addItem(itemView)
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        scrollView.contentInset = view.safeAreaInsets
    }

}

extension HomeSearchEmptyViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y + scrollView.contentInset.top
        separator.alpha = offset > 0 ? 1 : 0
        blurView.alpha = offset > 0 ? 1 : 0
    }

}
