//
//  CompareMenusViewController.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 3/4/24.
//

import EateryModel
import UIKit

class CompareMenusPageViewController: UIPageViewController {

    private var index = 0
    private var pages: [UIViewController] = []
    private var eateries: [Eatery] = []
    private var navigationView: CompareMenusNavigationView

    init(eateries: [Eatery], index: Int, navigationView: CompareMenusNavigationView) {
        self.eateries = eateries
        self.index = index
        self.navigationView = navigationView
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self

        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = .systemGray5
        appearance.currentPageIndicatorTintColor = .systemGray3
        appearance.backgroundColor = .clear

        setUpView()
    }

    func setUpPages(delegate: CompareMenusEateryViewControllerDelegate) {
        pages.removeAll()
        eateries.forEach { eatery in
            let vc = CompareMenusEateryViewController()
            vc.setUp(eatery: eatery)
            vc.delegate = delegate
            vc.view.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            pages.append(vc)
            vc.removeEateryButton.tap { [weak self] _ in
                guard let self else { return }
                if eateries.count == 1 {
                    navigationController?.popViewController(animated: true)
                } else {
                    eateries.removeAll { eats in
                        return eats == eatery
                    }
                    setUpPages(delegate: delegate)
                }
            }
        }
        if self.index >= eateries.count {
            self.index = min(self.index, eateries.count - 1)
            navigationView.configure(eatery: eateries[index])
            setViewControllers([pages[index]], direction: .reverse, animated: true, completion: nil)
        } else {
            navigationView.configure(eatery: eateries[index])
            setViewControllers([pages[index]], direction: .forward, animated: true, completion: nil)
        }
        if let page = pages[index] as? CompareMenusEateryViewController {
            page.setUpMenu(eatery: eateries[index])
        }
    }

    private func setUpView() {
        view.backgroundColor = .white
    }

    func tryNextPage() {
        if index < pages.count - 1 {
            index += 1
            navigationView.configure(eatery: eateries[index])

            setViewControllers([pages[index]], direction: .forward, animated: true, completion: nil)
            if let page = pages[index] as? CompareMenusEateryViewController {
                if !page.menuHasLoaded {
                    page.setUpMenu(eatery: eateries[index])
                }
            }
            updateNavArrows()
        }
    }

    func tryPrevPage() {
        if index > 0 {
            index -= 1
            navigationView.configure(eatery: eateries[index])
            setViewControllers([pages[index]], direction: .reverse, animated: true, completion: nil)
            if let page = pages[index] as? CompareMenusEateryViewController {
                if !page.menuHasLoaded {
                    page.setUpMenu(eatery: eateries[index])
                }
            }
            updateNavArrows()
        }
    }

    private func updateNavArrows() {
        if index == 0 {
            navigationView.prevEateryButton.content.tintColor = UIColor.Eatery.gray02
        } else {
            navigationView.prevEateryButton.content.tintColor = UIColor.Eatery.gray05
        }
        if index == pages.count - 1 {
            navigationView.nextEateryButton.content.tintColor = UIColor.Eatery.gray02
        } else {
            navigationView.nextEateryButton.content.tintColor = UIColor.Eatery.gray05
        }
    }

}

extension CompareMenusPageViewController: UIPageViewControllerDataSource {
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

extension CompareMenusPageViewController: UIPageViewControllerDelegate {

    func pageViewController(
        _ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let selectedController = pendingViewControllers.first,
           let index = pages.firstIndex(of: selectedController),
           let viewController = selectedController as? CompareMenusEateryViewController {
                self.index = index
                if !viewController.menuHasLoaded {
                    viewController.setUpMenu(eatery: eateries[index])
                }
           }
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        navigationView.configure(eatery: eateries[index])
        updateNavArrows()
    }
}

