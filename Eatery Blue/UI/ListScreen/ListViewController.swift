//
//  ListViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/27/21.
//

import Combine
import EateryModel
import UIKit

class ListViewController: UIViewController {

    let navigationView = ListNavigationView()

    let filterController = EateryFilterViewController()
    private var filtersView: UIView {
        filterController.view
    }

    let headerStackView = UIStackView()
    private let tableView = UITableView()

    // A view that holds the place of the filtersView in the stack view
    private let filterPlaceholder = UIView()

    var allEateries: [Eatery] = []
    private(set) var eateries: [Eatery] = []

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpSelf()
        setUpConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
        RootViewController.setStatusBarStyle(.darkContent)
    }

    private func setUpSelf() {
        view.backgroundColor = .white

        view.addSubview(tableView)
        setUpTableView()

        view.addSubview(navigationView)
        setUpNavigationView()

        setUpFilterController()
    }

    private func setUpFilterController() {
        addChild(filterController)
        view.addSubview(filterController.view)
        filterController.didMove(toParent: self)

        filterController.view.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }

    private func setUpTableView() {
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.alwaysBounceVertical = true
        tableView.estimatedRowHeight = 44
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none

        tableView.dataSource = self
        tableView.delegate = self

        tableView.addSubview(headerStackView)
        setUpHeaderStackView()
    }

    private func setUpHeaderStackView() {
        headerStackView.axis = .vertical
        headerStackView.spacing = 12
        headerStackView.alignment = .fill
        headerStackView.distribution = .fill
    }

    private func setUpNavigationView() {
        navigationView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)

        navigationView.backButton.on(UITapGestureRecognizer()) { [self] _ in
            navigationController?.popViewController(animated: true)
        }

        navigationView.searchButton.on(UITapGestureRecognizer()) { [self] _ in
            guard let navigationController = navigationController else { return }

            if navigationController.children.count > 1 {
                let previous = navigationController.children[navigationController.children.count - 2]
                if previous is HomeSearchModelController {
                    navigationController.popViewController(animated: true)
                    return
                }
            }

            let viewController = HomeSearchModelController()
            navigationController.pushViewController(viewController, animated: true)
        }
    }

    private func setUpConstraints() {
        navigationView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        filtersView.snp.makeConstraints { make in
            make.edges.equalTo(navigationView.filterPlaceholder)
        }

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        headerStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(tableView.contentLayoutGuide)
            make.width.equalTo(tableView.frameLayoutGuide)
        }
    }

    private func pushViewController(for eatery: Eatery) {
        let viewController = EateryModelController()
        viewController.setUp(eatery: eatery, allEateries: allEateries, isTracking: false)
        navigationController?.pushViewController(viewController, animated: true)
        viewController.setUpMenu(eatery: eatery)
    }

    func setUp(title: String?, description: String?) {
        loadViewIfNeeded()

        navigationView.titleLabel.text = title

        if let title = title {
            addTitleLabel(title)
        }

        if let description = description {
            addDescriptionLabel(description)
        }

        addFilterSpacerView()
    }

    func addTitleLabel(_ title: String) {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor.Eatery.blue

        let container = ContainerView(content: label)
        container.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        headerStackView.addArrangedSubview(container)
    }

    func addDescriptionLabel(_ description: String) {
        let label = UILabel()
        label.text = description
        label.numberOfLines = 0
        label.font = .preferredFont(for: .body, weight: .medium)
        label.textColor = UIColor.Eatery.gray06

        let container = ContainerView(content: label)
        container.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        headerStackView.addArrangedSubview(container)
    }

    func addFilterSpacerView() {
        headerStackView.addArrangedSubview(filterPlaceholder)

        filterPlaceholder.snp.makeConstraints { make in
            make.height.equalTo(filtersView)
        }
    }

    private func updateTableViewContentInset() {
        let topOffset = view.convert(navigationView.normalNavigationBar.bounds, from: navigationView.normalNavigationBar).maxY
        tableView.contentInset = UIEdgeInsets(top: topOffset, left: 0, bottom: view.safeAreaInsets.bottom, right: 0)
    }

    private func updateFiltersViewTransform() {
        let filterPosition = view.convert(navigationView.filterPlaceholder.bounds, from: navigationView.filterPlaceholder).minY
        let spacerPosition = view.convert(filterPlaceholder.bounds, from: filterPlaceholder).minY

        let transform = CGAffineTransform(
            translationX: 0,
            y: max(0, spacerPosition - filterPosition)
        )
        filtersView.transform = transform
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        view.layoutIfNeeded()
        updateTableViewContentInset()
        updateFiltersViewTransform()

        tableView.contentOffset = CGPoint(x: 0, y: -tableView.contentInset.top)
    }

    func updateEateries(eateries: [Eatery]) {
        self.eateries = eateries
        tableView.reloadData()
    }
    
}

extension ListViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateFiltersViewTransform()
        updateNavigationViewFadeInProgress()
    }

    private func updateNavigationViewFadeInProgress() {
        let filterPosition = view.convert(navigationView.filterPlaceholder.bounds, from: navigationView.filterPlaceholder).minY
        let spacerPosition = view.convert(filterPlaceholder.bounds, from: filterPlaceholder).minY

        if spacerPosition < filterPosition {
            navigationView.setFadeInProgress(1, animated: true)
        } else {
            navigationView.setFadeInProgress(0, animated: true)
        }
    }

}

extension ListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1 + eateries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let container = ContainerView(content: UIView())
            headerStackView.layoutIfNeeded()
            container.snp.makeConstraints { make in
                make.height.equalTo(headerStackView.frame.height + 12).priority(.high)
            }

            let cell = UITableViewCell(content: container)
            cell.selectionStyle = .none
            return cell

        } else {
            let eatery = eateries[indexPath.row - 1]
            let largeCardContent = EateryLargeCardContentView()
            
            largeCardContent.configure(eatery: eatery)

            let cardView = EateryCardVisualEffectView(content: largeCardContent)
            cardView.layoutMargins = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)

            let cell = ClearTableViewCell(content: cardView)
            cell.selectionStyle = .none
            return cell
        }
    }

}

extension ListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            let cell = tableView.cellForRow(at: indexPath)
            UIView.animate(withDuration: 0.15, delay: 0, options: .beginFromCurrentState) {
                cell?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
        }
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            let cell = tableView.cellForRow(at: indexPath)
            UIView.animate(withDuration: 0.15, delay: 0, options: .beginFromCurrentState) {
                cell?.transform = .identity
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            let eatery = eateries[indexPath.row - 1]
            pushViewController(for: eatery)
        }
    }

}
