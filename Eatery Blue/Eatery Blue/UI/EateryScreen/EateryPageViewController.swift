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
    private var eateries = [Eatery]()
    private var selectedIndex: Int
    
    init(eateries: [Eatery], selectedIndex: Int) {
        self.eateries = eateries
        self.selectedIndex = eateries.indices.contains(selectedIndex) ? selectedIndex : 0
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        dataSource = self
        
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
        let sortedEateries = eateries.sorted(by: { $0.index < $1.index })
        sortedEateries.forEach { eatery in
            let eateryVC = EateryModelController()
            eateryVC.setUp(eatery: eatery)
            pages.append(eateryVC)
        }
        setViewControllers([pages[selectedIndex]], direction: .forward, animated: true, completion: nil)
    }
    
}

extension EateryPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        let previousIndex = abs((index - 1) % pages.count)
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        let nextIndex = abs((index + 1) % pages.count)
        return pages[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let currentController = viewControllers?.first, let index = pages.firstIndex(of: currentController) else { return 0 }
        return index
    }
    
}
