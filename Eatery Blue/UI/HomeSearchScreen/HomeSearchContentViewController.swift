//
//  HomeSearchContentViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/1/22.
//

import UIKit

class HomeSearchContentViewController: UIViewController {

    private let priceNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .eatery
        return formatter
    }()

    enum Cell {
        case customView(view: UIView)
        case eatery(Eatery)
        case item(MenuItem, Eatery?)
    }

    private let blurView = UIVisualEffectView()
    let filterController = EateryFilterViewController()
    private var filterView: UIView { filterController.view }
    private let separator = HDivider()
    private let tableView = UITableView()

    private(set) var cells: [Cell] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        setUpConstraints()
    }

    private func setUpView() {
        view.addSubview(tableView)
        setUpTableView()

        view.addSubview(blurView)
        setUpBlurView()

        setUpFilterController()

        view.addSubview(separator)
    }

    private func setUpFilterController() {
        addChild(filterController)
        view.addSubview(filterView)
        filterController.didMove(toParent: self)
    }

    private func setUpBlurView() {
        blurView.effect = UIBlurEffect(style: .prominent)
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
    }

    private func setUpConstraints() {
        blurView.edgesToSuperview(excluding: .bottom)

        filterView.top(to: view.layoutMarginsGuide)
        filterView.leadingToSuperview()
        filterView.trailingToSuperview()
        filterView.bottom(to: blurView, offset: -12)

        separator.leadingToSuperview()
        separator.trailingToSuperview()
        separator.bottom(to: blurView)

        tableView.edgesToSuperview()
    }

    private func updateTableViewContentInset() {
        view.layoutIfNeeded()

        let top = blurView.convert(blurView.bounds, to: tableView.superview).maxY
        tableView.contentInset.top = top
        tableView.contentInset.bottom = view.safeAreaInsets.bottom
    }

    private func scrollToTop() {
        tableView.contentOffset = CGPoint(x: 0, y: -tableView.contentInset.top)
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        updateTableViewContentInset()
        scrollToTop()
    }

    func didSelectEatery(_ eatery: Eatery, at indexPath: IndexPath) {
    }

    func didSelectItem(_ item: MenuItem, at indexPath: IndexPath, eatery: Eatery?) {
    }

    func updateCells(_ cells: [Cell]) {
        self.cells = cells
        tableView.reloadData()
    }

}

extension HomeSearchContentViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cells.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch cells[indexPath.row] {
        case .customView(view: let view):
            let cell = ClearTableViewCell()
            cell.contentView.addSubview(view)
            view.edgesToSuperview()
            return cell

        case .eatery(let eatery):
            let cardView = EateryLargeCardView()
            cardView.imageView.kf.setImage(
                with: eatery.imageUrl,
                options: [
                    .backgroundDecode
                ]
            )
            cardView.imageTintView.alpha = EateryStatus(eatery.events).isOpen ? 0 : 0.5
            cardView.titleLabel.text = eatery.name
            let lines = EateryFormatter.default.formatEatery(
                eatery,
                style: .long,
                font: .preferredFont(for: .footnote, weight: .medium),
                userLocation: LocationManager.shared.userLocation,
                date: Date()
            )
            for (i, subtitleLabel) in cardView.subtitleLabels.enumerated() {
                if i < lines.count {
                    subtitleLabel.attributedText = lines[i]
                } else {
                    subtitleLabel.isHidden = true
                }
            }
            cardView.on(UITapGestureRecognizer()) { [self] _ in
                didSelectEatery(eatery, at: indexPath)
            }

            cardView.height(216)

            let cell = EateryLargeCardTableViewCell(cardView: cardView)
            cell.cell.layoutMargins = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
            return cell

        case .item(let item, let eatery):
            let view = SearchItemView()
            view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
            view.titleLabel.text = item.name

            if let price = item.price {
                view.priceLabel.text = priceNumberFormatter
                    .string(from: NSNumber(value: Double(price) / 100))
            } else {
                view.priceLabel.text = ""
            }

            if let description = item.description {
                view.descriptionLabel.isHidden = false
                view.descriptionLabel.text = description
            } else {
                view.descriptionLabel.isHidden = true
            }

            if let eatery = eatery {
                if let location = eatery.location {
                    view.sourceLabel.text = "\(eatery.name) · \(location)"
                } else {
                    view.sourceLabel.text = eatery.name
                }
            } else {
                view.sourceLabel.isHidden = true
            }

            view.on(UITapGestureRecognizer()) { [self] _ in
                didSelectItem(item, at: indexPath, eatery: eatery)
            }

            let container = ContainerView(content: view)
            container.cornerRadius = 8
            container.shadowRadius = 4
            container.shadowOffset = CGSize(width: 0, height: 4)
            container.shadowColor = UIColor(named: "ShadowLight")
            container.shadowOpacity = 0.25

            let cell = ClearTableViewCell()
            cell.contentView.addSubview(container)
            container.edgesToSuperview(insets: UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
            return cell
        }
    }

}

extension HomeSearchContentViewController: UITableViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y + scrollView.contentInset.top
        blurView.alpha = offset > 0 ? 1 : 0
        separator.alpha = offset > 0 ? 1 : 0
    }

}
