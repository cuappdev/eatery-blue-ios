//
//  HomeSearchViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import UIKit

class HomeSearchViewController: UIViewController {

    let searchBar = UISearchBar()
    let emptyController = HomeSearchEmptyModelController()
    let contentController = HomeSearchContentModelController()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        setUpConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        RootViewController.setStatusBarStyle(.darkContent)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        searchBar.searchTextField.becomeFirstResponder()
        searchBar.setShowsCancelButton(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        RootViewController.setStatusBarStyle(.lightContent)
        searchBar.setShowsCancelButton(false, animated: false)
    }

    private func setUpView() {
        hero.isEnabled = true

        setUpEmptyController()
        setUpContentController()

        view.addSubview(searchBar)
        setUpSearchBar()
    }

    private func setUpEmptyController() {
        addChild(emptyController)
        view.addSubview(emptyController.view)
        emptyController.didMove(toParent: self)
    }

    private func setUpContentController() {
        addChild(contentController)
        view.addSubview(contentController.view)
        contentController.didMove(toParent: self)

        contentController.view.alpha = 0
    }

    private func setUpSearchBar() {
        searchBar.hero.id = "searchBar"
        searchBar.placeholder = "Search for grub..."
        // UISearchBar has a built-in padding of 10px on the top and bottom
        searchBar.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        searchBar.backgroundImage = UIImage()
    }

    private func setUpConstraints() {
        searchBar.topToSuperview(usingSafeArea: true)
        searchBar.leadingToSuperview()
        searchBar.trailingToSuperview()

        emptyController.view.edgesToSuperview()

        contentController.view.edgesToSuperview()
    }

    private func updateChildSafeAreaInsets() {
        let top = searchBar.convert(searchBar.bounds, to: view).height
        emptyController.additionalSafeAreaInsets.top = top
        contentController.additionalSafeAreaInsets.top = top
    }

    override func viewLayoutMarginsDidChange() {
        view.layoutIfNeeded()
        updateChildSafeAreaInsets()
    }

}
