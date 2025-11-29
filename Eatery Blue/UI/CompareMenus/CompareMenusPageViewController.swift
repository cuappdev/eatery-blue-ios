//
//  CompareMenusPageViewController.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 3/4/24.
//

import EateryModel
import UIKit

protocol CompareMenusPageViewControllerDelegate: AnyObject {
    func compareMenusPageViewControllerDidFailToLoadMenus(_ vc: CompareMenusPageViewController)
}

class CompareMenusPageViewController: UIViewController {
    // MARK: - Properties (data)

    private let allEateries: [Eatery]
    private let eateries: [Eatery]
    private let tabsViewController: CompareMenusTabsViewController
    weak var delegate: CompareMenusPageViewControllerDelegate?
    private var didReportFailure = false

    // MARK: - Properties (view)

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let tabsViewSpacer = UIView()

    // MARK: - Init

    init(eateries: [Eatery], allEateries: [Eatery]) {
        self.eateries = eateries
        self.allEateries = allEateries
        tabsViewController = CompareMenusTabsViewController(eateries: eateries)

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
    }

    private func setUpView() {
        view.backgroundColor = UIColor.Eatery.default00

        setUpScrollView()
        view.addSubview(scrollView)

        setUpStackView()
        scrollView.addSubview(stackView)

        tabsViewSpacer.backgroundColor = UIColor.Eatery.gray01
        view.addSubview(tabsViewSpacer)

        setUpTabsViewController()
        view.addSubview(tabsViewController.view)

        setUpPages()
        setUpConstraints()
    }

    private func setUpTabsViewController() {
        addChild(tabsViewController)
        tabsViewController.setUpScrollView(delegate: self)
    }

    private func setUpScrollView() {
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
    }

    private func setUpStackView() {
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .fill
    }

    private func setUpPages() {
        for eatery in eateries {
            let vc = CompareMenusEateryViewController()
            vc.delegate = self
            vc.setUp(eatery: eatery, allEateries: allEateries)
            vc.setUpMenu(eatery: eatery)
            vc.view.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            addChild(vc)
            stackView.addArrangedSubview(vc.view)

            vc.view.snp.makeConstraints { make in
                make.top.equalTo(self.view.snp.top)
                make.bottom.equalTo(tabsViewController.view.snp.top)
                make.width.equalTo(self.view.snp.width)
            }
        }
    }

    private func setUpConstraints() {
        tabsViewController.view.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(tabBarController?.tabBar.frame.height ?? 0)
            make.height.equalTo(64)
        }

        tabsViewSpacer.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.bottom.equalTo(tabsViewController.view.snp.top)
            make.leading.trailing.equalToSuperview()
        }

        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(tabsViewController.view.snp.top)
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension CompareMenusPageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // if user swiping through pages
        if scrollView.superview == view {
            let percentage = scrollView.contentOffset.x / scrollView.contentSize.width
            if percentage.isNaN { return }
            tabsViewController.offsetScrollBy(percentage: percentage)

            // find tab index to highlight
            tabsViewController.highlightFromScrollPercentage(percentage)
        }

        // if user swiping through tabs
        if scrollView.superview == tabsViewController.view {
            let percentage = scrollView.contentOffset.x / scrollView.contentSize.width
            if percentage.isNaN { return }
            let trueOffsetX = self.scrollView.contentSize.width * percentage
            var scrollBounds = self.scrollView.bounds
            scrollBounds.origin = CGPoint(x: trueOffsetX, y: scrollBounds.origin.y)
            self.scrollView.bounds = scrollBounds

            // find tab index to highlight
            tabsViewController.highlightFromScrollPercentage(percentage)
        }
    }
}

extension CompareMenusPageViewController: CompareMenusEateryViewControllerDelegate {
    func compareMenusEateryViewControllerDidFailToLoadMenu(_: CompareMenusEateryViewController) {
        if didReportFailure { return }
        didReportFailure = true
        delegate?.compareMenusPageViewControllerDidFailToLoadMenus(self)
    }
}
