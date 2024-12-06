//
//  EateryPageViewController.swift
//  Eatery Blue
//
//  Created by Antoinette Marie Torres on 3/21/23.
//

import EateryModel
import UIKit

class EateryPageViewController: UIPageViewController {
    
    // MARK: - Properties (data)

    private var eateries: [Eatery] = []
    private var index: Int
    private var previousScrollOffset: CGFloat = 0
    private var pages: [UIViewController] = []

    // MARK: - Init

    init(eateries: [Eatery], index: Int) {
        self.eateries = eateries
        self.index = index

        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

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
    }
    
    override func viewDidLayoutSubviews() {
        view.subviews.forEach { subview in
            if subview is UIScrollView {
                subview.frame = view.bounds
            }
        }
        super.viewDidLayoutSubviews()
    }

    private func setUpPages() {
        eateries.forEach { eatery in
            let eateryVC = EateryModelController()
            eateryVC.setUp(eatery: eatery, isTracking: false)
            pages.append(eateryVC)
        }

        setViewControllers([pages[index]], direction: .forward, animated: true, completion: nil)
        if let page = pages[index] as? EateryModelController {
            page.setUpAnalytics(eateries[index])
            page.setUpMenu(eatery: eateries[index])
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

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        previousScrollOffset = 0
    }

}
