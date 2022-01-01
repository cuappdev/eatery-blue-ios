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
        return formatter
    }()

    enum Cell {
        case customView(view: UIView)
        case eatery(Eatery)
        case item(MenuItem, Eatery?)
    }

    private let blurView = UIVisualEffectView()
    private let separator = HDivider()
    let tableView = UITableView()

    var cells: [Cell] = []

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

        view.addSubview(separator)
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
        blurView.bottomToTop(of: view.safeAreaLayoutGuide)

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
                userLocation: nil,
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
                pushViewController(for: eatery)
            }

            cardView.height(216)

            let cell = EateryLargeCardTableViewCell(cardView: cardView)
            cell.cell.layoutMargins = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
            return cell

        case .item(let item, let eatery):
            let view = SearchItemView()
            view.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
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
                if let building = eatery.building {
                    view.sourceLabel.text = "\(eatery.name) · \(building)"
                } else {
                    view.sourceLabel.text = eatery.name
                }
            } else {
                view.sourceLabel.isHidden = true
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

    func pushViewController(for eatery: Eatery) {
        let viewController = EateryModelController()
        viewController.setUp(eatery: eatery)
        navigationController?.hero.isEnabled = false
        navigationController?.pushViewController(viewController, animated: true)
    }

}

extension HomeSearchContentViewController: UITableViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y + scrollView.contentInset.top
        blurView.alpha = offset > 0 ? 1 : 0
        separator.alpha = offset > 0 ? 1 : 0
    }

}
