//
//  EateryPageViewController.swift
//  Eatery Blue
//
//  Created by Antoinette Marie Torres on 3/21/23.
//

import EateryModel
import UIKit

class EateryPageViewController: UIPageViewController {
    
    private var pages = [UIViewController]()
    private var allEateries = [Eatery]()
    private var eateries = [Eatery]()
    private var index: Int
    private let compareMenusButton = CompareMenusButton()
    private var shouldOpenCompareMenusButton = true

    init(allEateries: [Eatery], eateries: [Eatery], index: Int) {
        self.allEateries = allEateries
        self.eateries = eateries
        self.index = index
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.Eatery.gray00
        dataSource = self
        delegate = self
        
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = .systemGray5
        appearance.currentPageIndicatorTintColor = .systemGray3
        appearance.backgroundColor = .clear
        
        setUpPages()
        setUpCompareMenusButton()
        view.addSubview(compareMenusButton)

        setUpConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        view.subviews.forEach { subview in
            if subview is UIScrollView {
                subview.frame = view.bounds
            }
        }
        super.viewDidLayoutSubviews()
    }

    private func setUpCompareMenusButton() {
        compareMenusButton.largeButtonPress { [weak self] _ in
            guard let self else { return }
            let viewController = CompareMenusSheetViewController(navController: navigationController, toCompareWith: eateries[index], eateries: allEateries)
            viewController.setUpSheetPresentation()
            tabBarController?.present(viewController, animated: true)
        }

        compareMenusButton.smallButtonPress { [weak self] _ in
            guard let self else { return }
            shouldOpenCompareMenusButton = false
            if !compareMenusButton.isCollapsed {
                compareMenusButton.snp.updateConstraints { make in
                    make.centerX.equalToSuperview().offset(self.view.frame.width * 3 / 8)
                }
            } else {
                compareMenusButton.snp.updateConstraints { make in
                    make.centerX.equalToSuperview()
                }
            }
            if #available(iOS 17.0, *) {
                UIView.animate(springDuration: 0.3, bounce: 0.3, initialSpringVelocity: 0.3, delay: 0, options: .curveEaseInOut) { [weak self] in
                    guard let self else { return }
                    view.layoutIfNeeded()
                }
            } else {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) { [weak self] in
                    guard let self else { return }
                    view.layoutIfNeeded()
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            guard let self else { return }
            if shouldOpenCompareMenusButton && compareMenusButton.isCollapsed {
                openCompareMenusButton()
            }
        }
    }

    private func setUpConstraints() {
        compareMenusButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(self.view.frame.width * 3 / 8)
            make.bottom.equalToSuperview().inset(108)
        }
    }

    private func setUpPages() {
       eateries.forEach { eatery in
            let eateryVC = EateryModelController()
            eateryVC.setUp(eatery: eatery)
            pages.append(eateryVC)
        }
        setViewControllers([pages[index]], direction: .forward, animated: true, completion: nil)
        if let page = pages[index] as? EateryModelController {
            page.setUpMenu(eatery: eateries[index])
        }
    }

    private func closeCompareMenusButton() {
        compareMenusButton.snp.updateConstraints { make in
            make.centerX.equalToSuperview().offset(self.view.frame.width * 3 / 8)
        }
        compareMenusButton.collapse()
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self else { return }
            view.layoutIfNeeded()
        }
    }

    private func openCompareMenusButton() {
        compareMenusButton.snp.updateConstraints { make in
            make.centerX.equalToSuperview()
        }
        compareMenusButton.expand()
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self else { return }
            view.layoutIfNeeded()
        }
    }
}

extension EateryPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        let previousIndex = index - 1
        if previousIndex >= 0 {
            return pages[previousIndex]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        let nextIndex = index + 1
        if nextIndex < pages.count {
            return pages[nextIndex]
        }
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let currentController = viewControllers?.first, let index = pages.firstIndex(of: currentController) else { return 0 }
        return index
    }
    
}

extension EateryPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(
        _ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
            if let selectedController = pendingViewControllers.first,
               let index = pages.firstIndex(of: selectedController),
               let viewController = selectedController as? EateryModelController {
                self.index = index
                if !viewController.menuHasLoaded {
                    viewController.setUpMenu(eatery: eateries[index])
                }
            }
        }
    
}
