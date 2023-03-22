//
//  EateryPageViewController.swift
//  Eatery Blue
//
//  Created by Antoinette Marie Torres on 3/21/23.
//

import UIKit
import EateryModel

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
        view.backgroundColor = .white
        delegate = self
        dataSource = self
        
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = .systemGray5
        appearance.currentPageIndicatorTintColor = .systemGray3
        
        setUpPages()
        
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

extension EateryPageViewController: UIPageViewControllerDelegate {
    
}

extension EateryPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index > 0 else { return pages[pages.count - 1] }
        
        return pages[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index + 1 < pages.count else { return pages[0] }
        
        return pages[index + 1]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let currentController = viewControllers?.first, let index = pages.firstIndex(of: currentController) else { return 0 }
        return index
    }
    
}
