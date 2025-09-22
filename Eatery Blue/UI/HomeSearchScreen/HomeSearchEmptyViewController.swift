//
//  HomeSearchEmptyViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/1/22.
//

import UIKit

class HomeSearchEmptyViewController: UIViewController {
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
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        blurView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

        separator.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top)
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
