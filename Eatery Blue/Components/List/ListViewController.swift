//
//  ListViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/27/21.
//

import os.log
import UIKit

class ListViewController: UIViewController {

    private let navigationView = ListNavigationView()
    private var filtersView: PillFiltersView {
        navigationView.filtersView
    }

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    // A view that holds the place of the filtersView in the stack view
    private let filterSpacerView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpSelf()
        setUpConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        RootViewController.setStatusBarStyle(.darkContent)

        view.layoutIfNeeded()
        updateScrollViewContentInset()
        updateFiltersViewTransform()
    }

    private func setUpSelf() {
        view.backgroundColor = .white

        view.addSubview(scrollView)
        setUpScrollView()

        view.addSubview(navigationView)
        setUpNavigationView()
    }

    private func setUpScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.alwaysBounceVertical = true
        scrollView.delegate = self

        scrollView.addSubview(stackView)
        setUpStackView()
    }

    private func setUpStackView() {
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 12
    }

    private func setUpNavigationView() {
        navigationView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)

        navigationView.backButton.on(UITapGestureRecognizer()) { [self] _ in
            navigationController?.popViewController(animated: true)
        }

        navigationView.searchButton.on(UITapGestureRecognizer()) { [self] _ in
            let viewController = HomeSearchViewController()
            navigationController?.pushViewController(viewController, animated: true)
        }

        setUpFiltersView()
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

    private func setUpConstraints() {
        navigationView.edgesToSuperview(excluding: .bottom)

        scrollView.edgesToSuperview()

        stackView.edgesToSuperview()
        stackView.widthToSuperview()
    }

    func setUp(
        _ eateries: [Eatery],
        title: String? = nil,
        description: String? = nil
    ) {
        loadViewIfNeeded()

        navigationView.titleLabel.text = title

        if let title = title {
            addTitleLabel(title)
        }

        if let description = description {
            addDescriptionLabel(description)
        }

        addFilterSpacerView()

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
                font: cardView.subtitleLabel2.font
            )

            cardView.on(UITapGestureRecognizer()) { [self] _ in
                pushViewController(for: eatery)
            }

            addCardView(cardView)
        }
    }

    private func pushViewController(for eatery: Eatery) {
        let viewController = EateryModelController()
        viewController.setUp(eatery: eatery)
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func addTitleLabel(_ title: String) {
        let label = UILabel()
        label.text = title
        label.font = .preferredFont(for: .largeTitle, weight: .bold)
        label.textColor = UIColor(named: "EateryBlue")

        let container = ContainerView(content: label)
        container.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.addArrangedSubview(container)
    }

    private func addDescriptionLabel(_ description: String) {
        let label = UILabel()
        label.text = description
        label.numberOfLines = 0
        label.font = .preferredFont(for: .body, weight: .medium)
        label.textColor = UIColor(named: "Gray06")

        let container = ContainerView(content: label)
        container.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.addArrangedSubview(container)
    }

    private func addFilterSpacerView() {
        stackView.addArrangedSubview(filterSpacerView)

        filterSpacerView.height(to: filtersView)
    }

    private func addCardView(_ view: EateryCardView) {
        view.height(216)

        let cell = EateryCardCell(cardView: view)
        cell.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.addArrangedSubview(cell)
    }

    private func updateScrollViewContentInset() {
        let topOffset = view.convert(navigationView.normalNavigationBar.bounds, from: navigationView.normalNavigationBar).maxY
        scrollView.contentInset = UIEdgeInsets(top: topOffset, left: 0, bottom: view.safeAreaInsets.bottom, right: 0)
    }

    private func updateFiltersViewTransform() {
        let filterPosition = view.convert(navigationView.filterPlaceholder.bounds, from: navigationView.filterPlaceholder).minY
        let spacerPosition = view.convert(filterSpacerView.frame, from: stackView).minY

        let transform = CGAffineTransform(
            translationX: 0,
            y: max(0, spacerPosition - filterPosition)
        )
        filtersView.transform = transform
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        view.layoutIfNeeded()
        updateScrollViewContentInset()
        updateFiltersViewTransform()

        scrollView.contentOffset = CGPoint(x: 0, y: -scrollView.contentInset.top)
    }
    
}

extension ListViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateFiltersViewTransform()
        updateNavigationViewFadeInProgress()
    }

    private func updateNavigationViewFadeInProgress() {
        let filterPosition = view.convert(navigationView.filterPlaceholder.bounds, from: navigationView.filterPlaceholder).minY
        let spacerPosition = view.convert(filterSpacerView.frame, from: stackView).minY

        if spacerPosition < filterPosition {
            navigationView.setFadeInProgress(1, animated: true)
        } else {
            navigationView.setFadeInProgress(0, animated: true)
        }
    }

}
