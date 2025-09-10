//
//  HomeSearchContentViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/1/22.
//

import EateryModel
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
    }

    private func setUpConstraints() {
        blurView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        filterView.snp.makeConstraints { make in
            make.top.equalTo(view.layoutMarginsGuide)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(blurView).inset(12)
        }

        separator.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(blurView)
        }

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
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

    func didSelectEatery(_: Eatery, at _: IndexPath) {}

    func didSelectItem(_: MenuItem, at _: IndexPath, eatery _: Eatery?) {}

    func updateCells(_ cells: [Cell]) {
        self.cells = cells
        tableView.reloadData()
    }
}

extension HomeSearchContentViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        cells.count
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch cells[indexPath.row] {
        case let .customView(view: view):
            let cell = ClearTableViewCell(content: view)
            cell.selectionStyle = .none
            return cell

        case let .eatery(eatery):
            let largeCardContent = EateryLargeCardView()

            let favorited = AppDelegate.shared.coreDataStack.metadata(eateryId: eatery.id).isFavorite

            largeCardContent.configure(eatery: eatery, favorited: favorited)

            let cardView = EateryCardVisualEffectView(content: largeCardContent)
            cardView.layoutMargins = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)

            let cell = ClearTableViewCell(content: cardView)
            cell.selectionStyle = .none
            return cell

        case let .item(item, eatery):
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
                if let locationDescription = eatery.locationDescription {
                    view.sourceLabel.text = "\(eatery.name) · \(locationDescription)"
                } else {
                    view.sourceLabel.text = eatery.name
                }
            } else {
                view.sourceLabel.isHidden = true
            }

            view.tap { [self] _ in
                didSelectItem(item, at: indexPath, eatery: eatery)
            }

            let cardView = EateryCardVisualEffectView(content: view)
            cardView.layoutMargins = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)

            let cell = ClearTableViewCell(content: cardView)
            cell.selectionStyle = .none
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

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        UIView.animate(withDuration: 0.15, delay: 0, options: .beginFromCurrentState) {
            cell?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        UIView.animate(withDuration: 0.15, delay: 0, options: .beginFromCurrentState) {
            cell?.transform = .identity
        }
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch cells[indexPath.row] {
        case let .eatery(eatery: eatery):
            didSelectEatery(eatery, at: indexPath)

        case let .item(item, eatery):
            didSelectItem(item, at: indexPath, eatery: eatery)

        case .customView:
            break
        }
    }
}
