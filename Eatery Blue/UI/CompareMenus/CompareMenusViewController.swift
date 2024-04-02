//
//  CompareMenusViewController.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi  on 3/5/24.
//

import EateryModel
import UIKit

class CompareMenusViewController: UIViewController {
    
    // MARK: -  Properties (data)

    private let pageController: CompareMenusPageViewController
    private let allEateries: [Eatery]
    private let comparedEateries: [Eatery]

    // MARK: - Properties (view)

    private let navigationView = CompareMenusNavigationView()

    // MARK: - Init

    init(allEateries: [Eatery], comparedEateries: [Eatery]) {
        self.pageController = CompareMenusPageViewController(eateries: comparedEateries, allEateries: allEateries)
        self.allEateries = allEateries
        self.comparedEateries = comparedEateries
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - Setup

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
        navigationView.backButton.buttonPress { [weak self] _ in
            guard let self else { return }
            navigationController?.popViewController(animated: true)
        }

        navigationView.editButton.buttonPress { [weak self] _ in
            guard let self else { return }
            navigationController?.popViewController(animated: true)
            let selectionViewController = CompareMenusSheetViewController(parentNavigationController: navigationController, allEateries: allEateries , selectedEateries: comparedEateries, selectedOn: true)
            selectionViewController.setUpSheetPresentation()
            navigationController?.present(selectionViewController, animated: true)
        }
    }

    private func setUpConstraints() {
        navigationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.height.equalTo(56)
        }

        pageController.view.snp.makeConstraints { make in
            make.trailing.leading.bottom.equalToSuperview()
            make.top.equalTo(navigationView.snp.bottom)
        }
    }
}
