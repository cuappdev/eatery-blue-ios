//
//  MenusViewController.swift
//  Eatery Blue
//
//  Created by Antoinette Marie Torres on 9/13/23.
//

import Combine
import CoreLocation
import EateryModel
import UIKit
import Kingfisher

/// Used for Expanding Cell
struct ExpandedEatery {
    let eatery: Eatery
    var isExpanded: Bool = false
}

class MenusViewController: UIViewController {
    
    enum Cell {
        case dayPicker
        case customView(view: UIView)
        case titleLabel(title: String)
        case loadingLabel(title: String)
        case expandableCard(expandedEatery: ExpandedEatery)
        case loadingCard
    }
    
    private struct Constants {
        static let daysLayoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 16)
        static let labelLayoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 8, right: 16)
        static let cardViewLayoutMargins = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        static let customViewLayoutMargins = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
    }
    
    let navigationView = MenusNavigationView()
    private let tableView = UITableView()
    private let tableHeaderView = UIView()
    
    private(set) var cells: [Cell] = []
    private(set) var eateries: [Eatery] = []
    private(set) var extraIndex: Int = 0
    private lazy var setLoadingInset: Void = {
        scrollToTop(animated: false)
    }()
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        tableView.register(MenuDayPickerTableViewCell.self, forCellReuseIdentifier: "MenuDayPickerCell")
        tableView.register(MenuCardTableViewCell.self, forCellReuseIdentifier: "MenuCardCell")
        tableView.register(EmptyTableFooterView.self, forHeaderFooterViewReuseIdentifier: EmptyTableFooterView.reuse)

        setUpView()
        setUpConstraints()
        
        updateScrollViewContentInset()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        RootViewController.setStatusBarStyle(.lightContent)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateScrollViewContentInset()
        _ = setLoadingInset
    }
    
    private func setUpView() {
        view.addSubview(tableView)
        setUpTableView()
        
        view.addSubview(navigationView)
        setUpNavigationView()
    }
    
    private func setUpTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = true
        tableView.showsVerticalScrollIndicator = false
        tableView.alwaysBounceVertical = true
        tableView.showsHorizontalScrollIndicator = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 216
        tableView.tableHeaderView = tableHeaderView
        tableView.tableFooterView = UIView()
    }
    
    private func setUpNavigationView() {
        navigationView.logoRefreshControl.delegate = self
        navigationView.setFadeInProgress(0)
    }
    
    private func setUpConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        navigationView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(tableHeaderView.snp.top).priority(.low)
            make.bottom.greaterThanOrEqualTo(tableHeaderView.snp.top)
        }
    }
    
    private func updateScrollViewContentInset() {
        let top = navigationView.computeExpandedHeight()

        tableView.contentInset.top = top
        tableView.contentInset.bottom = view.safeAreaInsets.bottom
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        updateScrollViewContentInset()
    }
    
    func scrollToTop(animated: Bool) {
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: animated)
    }
    
    func updateCells(cells: [Cell], allEateries: [Eatery], eateryStartIndex: Int) {
        self.cells = cells
        tableView.reloadData()
    }
}

extension MenusViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: EmptyTableFooterView.reuse)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = cells[indexPath.section]

        switch cellType {
        case .dayPicker:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuDayPickerCell", for: indexPath) as! MenuDayPickerTableViewCell
            return cell
        case .customView(let view):
            let container = ContainerView(content: view)
            container.layoutMargins = Constants.customViewLayoutMargins
            
            let cell = ClearTableViewCell(content: container)
            cell.selectionStyle = .none
            return cell
        case .titleLabel(title: let title):
            let label = UILabel()
            label.text = title
            label.font = .preferredFont(for: .title2, weight: .semibold)
            
            let container = ContainerView(content: label)
            container.layoutMargins = Constants.labelLayoutMargins
            
            let cell = ClearTableViewCell(content: container)
            cell.selectionStyle = .none
            return cell
        case .loadingLabel(title: let title):
            let label = UILabel()
            label.text = title
            label.textColor = UIColor.Eatery.gray02
            label.font = .preferredFont(for: .title2, weight: .semibold)
            
            let container = ContainerView(content: label)
            container.layoutMargins = Constants.labelLayoutMargins
            
            let cell = ClearTableViewCell(content: container)
            cell.selectionStyle = .none
            return cell
        case .loadingCard:
            let contentView = EateryExpandLoadingCardView()
            
            let cardView = EateryCardVisualEffectView(content: contentView)
            cardView.layoutMargins = Constants.cardViewLayoutMargins
            
            let cell = ClearTableViewCell(content: cardView)
            cell.selectionStyle = .none
            return cell
        case .expandableCard(expandedEatery: let expandedEatery):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCardCell", for: indexPath) as? MenuCardTableViewCell else { return UITableViewCell() }
            cell.configure(expandedEatery: expandedEatery)
            return cell
        }
    }
    
}
    
extension MenusViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section > 2 {
            return 12
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch cells[indexPath.section] {
        case .dayPicker:
            print("Day selected")
        case .expandableCard(expandedEatery: let expandedEatery):
            if expandedEatery.eatery.isOpen {
                self.cells[indexPath.section] = .expandableCard(expandedEatery: ExpandedEatery(eatery: expandedEatery.eatery, isExpanded: !expandedEatery.isExpanded))
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        default:
            break
        }
    }
    
}

extension MenusViewController: UIScrollViewDelegate {

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        handlePullToRefresh(scrollView)
        handleSnapping(scrollView, velocity: velocity, targetContentOffset: targetContentOffset)
    }

    private func handleSnapping(_ scrollView: UIScrollView, velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
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
            CGPoint(x: 0, y: navigationView.computeExpandedHeight()),
            from: navigationView
        ).y

        if navigationBarExpandedPosition <= finalPosition && finalPosition <= navigationBarNormalPosition {
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

    private func handlePullToRefresh(_ scrollView: UIScrollView) {
        let deltaFromTop = tableView.contentOffset.y + tableView.contentInset.top
        let pullProgress = (-deltaFromTop - 22) / 66

        if pullProgress > 1.1 {
            navigationView.logoRefreshControl.beginRefreshing()
            updateScrollViewContentInset()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        handleNavigationView()
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

        if currentPosition > navigationBarNormalPosition - 16 {
            navigationView.setFadeInProgress(1, animated: true)
        } else {
            navigationView.setFadeInProgress(0, animated: true)
        }

        let deltaFromTop = tableView.contentOffset.y + tableView.contentInset.top

        if !navigationView.logoRefreshControl.isRefreshing {
            let pullProgress = (-deltaFromTop - 22) / 66
            navigationView.logoRefreshControl.setPullProgress(pullProgress)
        }

        let fadeDistance = navigationView.logoRefreshControl.bounds.height
        let progress = max(0, min(1, 1 - deltaFromTop / fadeDistance))
        navigationView.logoRefreshControl.alpha = progress
        navigationView.largeTitleLabel.alpha = progress
    }

}

extension MenusViewController: LogoRefreshControlDelegate {

    func logoRefreshControlDidBeginRefreshing(_ sender: LogoRefreshControl) {
    }

    func logoRefreshControlDidEndRefreshing(_ sender: LogoRefreshControl) {
        UIView.animate(withDuration: 0.15) { [self] in
            updateScrollViewContentInset()
        }
    }

}


extension MenusViewController {
    
    class EmptyTableFooterView: UITableViewHeaderFooterView {
        static let reuse = "EmptyTableFooterViewReuse"
    }
    
}

