//
//  CompareMenusViewController.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi  on 3/5/24.
//

import EateryModel
import UIKit

class CompareMenusViewController: UIViewController {
    
    let navigationView = CompareMenusNavigationView()
    let pageController: CompareMenusPageViewController

    init(eateries: [Eatery], index: Int) {
        self.pageController = CompareMenusPageViewController(eateries: eateries, index: index, navigationView: navigationView)
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        view.backgroundColor = .white
        addChild(pageController)
        view.addSubview(pageController.view)

        setUpNavigationView()
        view.addSubview(navigationView)

        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpNavigationView() {
        navigationView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 12, right: 16)
        navigationView.prevEateryButton.buttonPress { [weak self] _ in
            guard let self else { return }
            pageController.tryPrevPage()
        }
        navigationView.nextEateryButton.buttonPress { [weak self] _ in
            guard let self else { return }
            pageController.tryNextPage()

        }
        navigationView.backButton.buttonPress { [weak self] _ in
            guard let self else { return }
            navigationController?.popViewController(animated: true)
        }
    }

    private func setUpConstraints() {
        navigationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.height.equalTo(108)
        }

        pageController.view.snp.makeConstraints { make in
            make.trailing.leading.bottom.equalToSuperview()
            make.top.equalTo(navigationView.snp.bottom)
        }
    }
}
