//
//  FavoritesNavigationView.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 10/26/24.
//

import UIKit

protocol FavoritesNavigationViewDelegate: AnyObject {
    func favoritesNavigationViewDidTapAdd(_ view: FavoritesNavigationView)
}

class FavoritesNavigationView: UIView {
    // MARK: - Properties (view)

    private let addButton = ButtonView(content: UIImageView())
    private let backButton = ButtonView(pillContent: UIImageView())
    private let eateriesTab = TabButtonView()
    private let itemsTab = TabButtonView()
    private let placeholderView = UIView()
    private let titleLabel = UILabel()

    // MARK: - Properties (data)

    /// The controller that this view uses to pop on back button press
    var navigationController: UINavigationController?

    /// Called when the add (+) button is pressed
    weak var delegate: FavoritesNavigationViewDelegate?

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
        layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 0, right: 16)
        backgroundColor = UIColor.Eatery.default00

        addSubview(backButton)
        setUpBackButton()

        addSubview(addButton)
        setUpAddButton()

        addSubview(titleLabel)
        setUpTitleLabel()

        addSubview(eateriesTab)
        setUpEateriesTab()

        addSubview(itemsTab)
        setUpItemsTab()

        addSubview(placeholderView)

        setUpConstraints()
    }

    private func setUpBackButton() {
        backButton.content.image = UIImage(named: "ArrowLeft")?.withRenderingMode(.alwaysTemplate)
        backButton.content.tintColor = UIColor.Eatery.primaryText
        backButton.content.contentMode = .scaleAspectFit
        backButton.shadowColor = UIColor.Eatery.primaryText
        backButton.shadowOffset = CGSize(width: 0, height: 4)
        backButton.shadowOpacity = 0.25
        backButton.backgroundColor = UIColor.Eatery.default00
        backButton.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        backButton.buttonPress { [weak self] _ in
            guard let self else { return }
            navigationController?.hero.isEnabled = false
            navigationController?.popViewController(animated: true)
        }
    }

    private func setUpAddButton() {
        addButton.content.image = UIImage(systemName: "plus")
        addButton.content.tintColor = UIColor.Eatery.primaryText
        addButton.content.contentMode = .scaleAspectFit
        addButton.layoutMargins = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)

        addButton.buttonPress { [weak self] _ in
            guard let self else { return }
            delegate?.favoritesNavigationViewDidTapAdd(self)
        }
    }

    private func setUpTitleLabel() {
        titleLabel.text = "Favorites"
        titleLabel.font = .eateryNavigationBarLargeTitleFont
        titleLabel.textColor = UIColor.Eatery.blue
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

    private func setUpConstraints() {
        backButton.snp.makeConstraints { make in
            make.leading.equalTo(layoutMarginsGuide.snp.leading)
            make.top.equalTo(layoutMarginsGuide.snp.top)
            make.width.height.equalTo(40)
        }

        addButton.snp.makeConstraints { make in
            make.trailing.equalTo(layoutMarginsGuide.snp.trailing)
            make.centerY.equalTo(backButton)
            make.width.height.equalTo(32)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(layoutMarginsGuide.snp.leading)
            make.trailing.equalTo(layoutMarginsGuide.snp.trailing)
            make.top.equalTo(backButton.snp.bottom).offset(12)
        }

        placeholderView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(8)
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.height.equalTo(34)
            make.bottom.equalTo(layoutMarginsGuide)
        }

        eateriesTab.snp.makeConstraints { make in
            make.height.equalTo(34)
            make.trailing.equalTo(placeholderView.snp.leading)
            make.leading.equalTo(layoutMarginsGuide)
            make.centerY.equalTo(placeholderView)
        }

        itemsTab.snp.makeConstraints { make in
            make.height.equalTo(34)
            make.leading.equalTo(placeholderView.snp.trailing)
            make.trailing.equalTo(layoutMarginsGuide)
            make.centerY.equalTo(placeholderView)
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
