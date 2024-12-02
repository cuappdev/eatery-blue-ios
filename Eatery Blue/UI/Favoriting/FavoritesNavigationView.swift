//
//  FavoritesNavigationView.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 10/26/24.
//

import UIKit

class FavoritesNavigationView: UIView {

    // MARK: - Properties (View)

    private let backButton = ButtonView(content: UIImageView())
    private let searchButton = ButtonView(content: UIImageView())
    private let searchBar = UISearchBar()

    private let titleLabel = UILabel()
    private let eateriesTab = TabButtonView()
    private let itemsTab = TabButtonView()

    private let placeholderView = UIView()

    // MARK: - Properties (Data)

    var navigationController: UINavigationController?
    var tabButtonsDelegate: TabButtonViewDelegate? {
        didSet {
            eateriesTab.delegate = tabButtonsDelegate
            itemsTab.delegate = tabButtonsDelegate
        }
    }
    var searchDelegate: UISearchBarDelegate? {
        didSet {
            searchBar.delegate = searchDelegate
        }
    }

    var searchShown = false {
        didSet {
            if !searchShown {

                searchBar.text = ""
                searchDelegate?.searchBar?(searchBar, textDidChange: "")

                UIView.animate(withDuration: 0.1) { [weak self] in
                    guard let self else { return }
                    searchBar.snp.updateConstraints { make in
                        make.height.equalTo(0)
                    }

                    layoutIfNeeded()
                }
            } else {
                UIView.animate(withDuration: 0.1) { [weak self] in
                    guard let self else { return }
                    searchBar.snp.updateConstraints { make in
                        make.height.equalTo(36)
                    }

                    layoutIfNeeded()
                }
            }
        }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Set Up

    private func setUp() {
        self.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 4, right: 16)
        backgroundColor = .white

        addSubview(backButton)
        setUpBackButton()
        
        addSubview(titleLabel)
        setUpTitleLabel()

        addSubview(searchButton)
        setUpSearchButton()

        addSubview(eateriesTab)
        setUpEateriesTab()

        addSubview(itemsTab)
        setUpItemsTab()

        addSubview(placeholderView)

        addSubview(searchBar)
        setUpSearchBar()

        setUpConstraints()
    }

    private func setUpBackButton() {
        backButton.content.image = UIImage(named: "ArrowLeft")
        backButton.shadowColor = UIColor.Eatery.black
        backButton.shadowOffset = CGSize(width: 0, height: 4)
        backButton.backgroundColor = .white
        backButton.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 16)

        backButton.buttonPress { [weak self] _ in
            guard let self else { return }

            navigationController?.hero.isEnabled = false
            navigationController?.popViewController(animated: true)
        }
    }

    private func setUpTitleLabel() {
        titleLabel.text = "Favorites"
        titleLabel.font = .eateryNavigationBarLargeTitleFont
        titleLabel.textColor = UIColor.Eatery.blue
    }

    private func setUpSearchButton() {
        searchButton.content.image = UIImage(named: "Search")
        searchButton.shadowColor = UIColor.Eatery.black
        searchButton.shadowOffset = CGSize(width: 0, height: 4)
        searchButton.backgroundColor = .white
        searchButton.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 0)

        searchButton.buttonPress { [weak self] _ in
            guard let self else { return }

            searchShown = true
            print("good")
            searchBar.becomeFirstResponder()
        }
    }

    private func setUpEateriesTab() {
        eateriesTab.text = "Eateries"
        eateriesTab.buttonPress { [weak self] _ in
            guard let self else { return }
            itemsTab.selected = false
        }

        eateriesTab.selected = true
    }

    private func setUpItemsTab() {
        itemsTab.text = "Items"
        itemsTab.buttonPress { [weak self] _ in
            guard let self else { return }
            eateriesTab.selected = false
        }

        itemsTab.selected = false
    }

    private func setUpSearchBar() {
        searchBar.setShowsCancelButton(true, animated: false)
        searchBar.placeholder = "Search for faves..."
        searchBar.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = .white
    }

    private func setUpConstraints() {
        backButton.snp.makeConstraints { make in
            make.leading.equalTo(layoutMarginsGuide.snp.leading)
            make.top.equalTo(layoutMarginsGuide.snp.top)
            make.width.height.equalTo(42)
        }

        searchButton.snp.makeConstraints { make in
            make.trailing.equalTo(layoutMarginsGuide.snp.trailing)
            make.centerY.equalTo(backButton.snp.centerY)
            make.width.height.equalTo(42)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(layoutMarginsGuide.snp.leading).inset(4)
            make.trailing.equalTo(layoutMarginsGuide.snp.trailing)
            make.top.equalTo(backButton.snp.bottom)
            make.height.equalTo(42)
        }

        placeholderView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(8)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.bottom.equalTo(layoutMarginsGuide)
        }

        eateriesTab.snp.makeConstraints { make in
            make.height.equalTo(36)
            make.trailing.equalTo(placeholderView.snp.leading)
            make.leading.bottom.equalTo(layoutMarginsGuide)
        }

        itemsTab.snp.makeConstraints { make in
            make.height.equalTo(36)
            make.leading.equalTo(placeholderView.snp.trailing)
            make.trailing.bottom.equalTo(layoutMarginsGuide)
        }

        searchBar.snp.makeConstraints { make in
            make.top.equalTo(layoutMarginsGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0)
        }
    }

}

extension FavoritesNavigationView: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !scrollView.isDragging { return }

        if scrollView.contentOffset.x > scrollView.contentSize.width / 4 {
            self.eateriesTab.selected = false
            self.itemsTab.selected = true
        } else {
            self.eateriesTab.selected = true
            self.itemsTab.selected = false
        }
    }

}
