//
//  FavoritesNavigationView.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 10/26/24.
//

import UIKit

class FavoritesNavigationView: UIView {
    // MARK: - Properties (view)

    private let backButton = UIButton(type: .system)
    private let eateriesTab = TabButtonView()
    private let itemsTab = TabButtonView()
    private let placeholderView = UIView()
    private let searchBar = UISearchBar()
    private let searchButton = UIButton(type: .system)
    private let titleLabel = UILabel()

    // MARK: - Properties (data)

    /// The controller that this view uses to pop on back button press
    var navigationController: UINavigationController?
    /// Search bar delegate, called when search bar text changes
    var searchDelegate: UISearchBarDelegate? {
        didSet {
            searchBar.delegate = searchDelegate
        }
    }

    /// Whether or not the search bar should be shown
    var searchShown = false {
        didSet {
            guard searchShown != oldValue else { return }

            if searchShown {
                searchBar.isHidden = false
                searchBar.setShowsCancelButton(true, animated: false)
            } else {
                searchBar.text = ""
                searchDelegate?.searchBar?(searchBar, textDidChange: "")
                searchBar.resignFirstResponder()
            }

            let shown = searchShown
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                guard let self else { return }
                searchBar.alpha = shown ? 1 : 0
                titleLabel.alpha = shown ? 0 : 1
            }, completion: { [weak self] _ in
                guard let self, searchShown == shown else { return }
                searchBar.isHidden = !shown
                if !shown {
                    searchBar.setShowsCancelButton(false, animated: false)
                }
            })

            if searchShown {
                searchBar.becomeFirstResponder()
            }
        }
    }

    /// Tab buttons delegate, called when tab buttons are pressed
    var tabButtonsDelegate: TabButtonViewDelegate? {
        didSet {
            eateriesTab.delegate = tabButtonsDelegate
            itemsTab.delegate = tabButtonsDelegate
        }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSelf()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Set Up

    private func setUpSelf() {
        layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 4, right: 16)
        backgroundColor = UIColor.Eatery.default00

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

        bringSubviewToFront(backButton)
        bringSubviewToFront(searchButton)
    }

    private func setUpBackButton() {
        configureNavigationButton(backButton, imageNamed: "ArrowLeft")
        backButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }

            navigationController?.hero.isEnabled = false
            navigationController?.popViewController(animated: true)
        }, for: .touchUpInside)
    }

    private func setUpTitleLabel() {
        titleLabel.text = "Favorites"
        titleLabel.font = .eateryNavigationBarLargeTitleFont
        titleLabel.textColor = UIColor.Eatery.blue
    }

    private func setUpSearchButton() {
        configureNavigationButton(searchButton, imageNamed: "Search")
        searchButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }

            searchShown = true
            searchBar.becomeFirstResponder()
        }, for: .touchUpInside)
    }

    private func configureNavigationButton(_ button: UIButton, imageNamed imageName: String) {
        var configuration: UIButton.Configuration
        if #available(iOS 26.0, *) {
            configuration = .glass()
        } else {
            configuration = .filled()
            configuration.baseBackgroundColor = UIColor.Eatery.default01
        }

        configuration.image = UIImage(named: imageName)
        configuration.baseForegroundColor = UIColor.Eatery.primaryText
        configuration.cornerStyle = .capsule
        configuration.contentInsets = .zero
        button.configuration = configuration
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
        searchBar.setShowsCancelButton(false, animated: false)
        searchBar.placeholder = "Search for faves..."
        searchBar.searchBarStyle = .minimal
        searchBar.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = .clear
        searchBar.alpha = 0
        searchBar.isHidden = true
        searchBar.setContentHuggingPriority(.fittingSizeLevel, for: .vertical)
        searchBar.setContentCompressionResistancePriority(.fittingSizeLevel, for: .vertical)
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
            make.leading.trailing.equalToSuperview()
            make.centerY.equalTo(titleLabel)
            make.height.equalTo(56)
        }
    }
}

extension FavoritesNavigationView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !scrollView.isDragging {
            return
        }

        if scrollView.contentOffset.x > scrollView.contentSize.width / 4 {
            eateriesTab.selected = false
            itemsTab.selected = true
        } else {
            eateriesTab.selected = true
            itemsTab.selected = false
        }
    }
}
