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
    
    init(eateries: [Eatery]) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
        self.eateries = eateries
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
        for subview in view.subviews {
            if subview is UIScrollView {
                subview.frame = self.view.bounds
            }
        }
        super.viewDidLayoutSubviews()
    }
    
    private func setUpPages() {
        eateries.forEach { eatery in
            let eateryVC = EateryModelController()
            eateryVC.setUp(eatery: eatery)
            pages.append(eateryVC)
        }
        setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
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
