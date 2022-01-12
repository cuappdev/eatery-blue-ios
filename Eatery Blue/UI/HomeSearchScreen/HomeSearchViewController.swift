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

        navigationController?.hero.isEnabled = true
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
        searchBar.setShowsCancelButton(true, animated: false)
        searchBar.hero.id = "searchBar"
        searchBar.placeholder = "Search for grub..."
        // UISearchBar has a built-in padding of 10px on the top and bottom
        searchBar.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        searchBar.backgroundImage = UIImage()
    }

    private func setUpConstraints() {
        searchBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }

        emptyController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
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
