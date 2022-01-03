//
//  EateryNavigationView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/23/21.
//

import UIKit

class EateryNavigationView: UIView {

    let backgroundView = UIView()

    let stackView = UIStackView()

    let normalNavigationBar = UIView()
    let backButton = ContainerView(pillContent: UIImageView())
    let titleLabel = UILabel()
    let favoriteButton = ContainerView(pillContent: UIImageView())

    let scrollView = UIScrollView()
    let categoriesBackground = UIStackView()
    let categoriesForeground = UIStackView()
    let foregroundMask = PillView()

    private let divider = HDivider()

    private(set) var fadeInProgress: Double = 0
    private(set) var highlightedCategoryIndex: Int? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()

        setFadeInProgress(fadeInProgress)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        addSubview(backgroundView)
        setUpBackgroundView()

        addSubview(stackView)
        setUpStackView()

        addSubview(divider)
    }

    private func setUpStackView() {
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .center

        stackView.addArrangedSubview(normalNavigationBar)
        setUpNormalNavigationBar()

        stackView.addArrangedSubview(scrollView)
        setUpScrollView()
    }

    private func setUpBackgroundView() {
        backgroundView.backgroundColor = .white
    }

    private func setUpNormalNavigationBar() {
        normalNavigationBar.addSubview(backButton)
        setUpBackButton()

        normalNavigationBar.addSubview(titleLabel)
        setUpTitleLabel()

        normalNavigationBar.addSubview(favoriteButton)
        setUpFavoriteButton()
    }

    private func setUpBackButton() {
        backButton.content.image = UIImage(named: "ArrowLeft")
        backButton.shadowColor = UIColor(named: "Black")
        backButton.shadowOffset = CGSize(width: 0, height: 4)
        backButton.backgroundColor = .white
        backButton.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }

    private func setUpTitleLabel() {
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = UIColor(named: "Black")
        titleLabel.textAlignment = .center
    }

    private func setUpFavoriteButton() {
        favoriteButton.content.image = UIImage(named: "FavoriteSelected")
        favoriteButton.shadowColor = UIColor(named: "Black")
        favoriteButton.shadowOffset = CGSize(width: 0, height: 4)
        favoriteButton.backgroundColor = .white
        favoriteButton.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }

    private func setUpScrollView() {
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false

        scrollView.addSubview(categoriesBackground)
        setUpCategoriesStackView(categoriesBackground)
        categoriesBackground.isUserInteractionEnabled = true

        scrollView.addSubview(categoriesForeground)

        setUpCategoriesStackView(categoriesForeground)
        categoriesForeground.isUserInteractionEnabled = false
        categoriesForeground.backgroundColor = UIColor(named: "Black")

        // Set some completely opaque color for the foregroundMask
        foregroundMask.backgroundColor = .white
        categoriesForeground.mask = foregroundMask
    }

    private func setUpCategoriesStackView(_ stackView: UIStackView) {
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fill
        stackView.alignment = .fill
    }

    private func setUpConstraints() {
        backgroundView.edgesToSuperview()

        stackView.top(to: layoutMarginsGuide)
        stackView.leadingToSuperview()
        stackView.trailingToSuperview()
        stackView.bottom(to: layoutMarginsGuide)

        normalNavigationBar.height(44)
        normalNavigationBar.leading(to: layoutMarginsGuide)
        normalNavigationBar.trailing(to: layoutMarginsGuide)

        backButton.centerYToSuperview()
        backButton.leadingToSuperview()
        backButton.width(40)
        backButton.height(40)

        titleLabel.leadingToTrailing(of: backButton, offset: 8, relation: .equalOrGreater)
        titleLabel.topToSuperview()
        titleLabel.bottomToSuperview()
        titleLabel.centerXToSuperview()
        titleLabel.trailingToLeading(of: favoriteButton, offset: 8, relation: .equalOrLess)

        favoriteButton.centerYToSuperview()
        favoriteButton.trailingToSuperview()
        favoriteButton.width(40)
        favoriteButton.height(40)

        scrollView.widthToSuperview()

        setUpCategoriesStackViewConstraints(categoriesBackground)
        setUpCategoriesStackViewConstraints(categoriesForeground)

        divider.edgesToSuperview(excluding: .top)
    }

    private func setUpCategoriesStackViewConstraints(_ stackView: UIStackView) {
        stackView.edgesToSuperview()
        stackView.height(to: scrollView)
    }

    func setFadeInProgress(_ progress: Double) {
        backgroundView.alpha = progress
        backButton.shadowOpacity = 0.25 * (1 - progress)
        favoriteButton.shadowOpacity = 0.25 * (1 - progress)
        titleLabel.alpha = progress
        scrollView.alpha = progress
        divider.alpha = progress
    }

    func setFadeInProgress(_ progress: Double, animated: Bool) {
        let progress = max(0, min(1, progress))
        self.fadeInProgress = progress

        if animated {
            UIView.animate(withDuration: 0.125) {
                self.setFadeInProgress(progress)
            }
        } else {
            setFadeInProgress(progress)
        }
    }

    func addCategory(_ title: String, onTap: (() -> Void)? = nil) {
        let backgroundContainer = ContainerView(content: UILabel())
        let foregroundContainer = ContainerView(content: UILabel())

        backgroundContainer.content.text = title
        foregroundContainer.content.text = backgroundContainer.content.text

        backgroundContainer.content.font = .preferredFont(for: .footnote, weight: .semibold)
        foregroundContainer.content.font = .preferredFont(for: .footnote, weight: .medium)

        backgroundContainer.layoutMargins = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        foregroundContainer.layoutMargins = backgroundContainer.layoutMargins

        backgroundContainer.content.textColor = UIColor(named: "Gray05")
        foregroundContainer.content.textColor = .white

        categoriesBackground.addArrangedSubview(backgroundContainer)
        categoriesForeground.addArrangedSubview(foregroundContainer)

        backgroundContainer.width(to: foregroundContainer)

        backgroundContainer.on(UITapGestureRecognizer()) { _ in
            onTap?()
        }
        foregroundContainer.isUserInteractionEnabled = false
    }

    func removeAllCategories() {
        for view in categoriesBackground.arrangedSubviews {
            view.removeFromSuperview()
        }

        for view in categoriesForeground.arrangedSubviews {
            view.removeFromSuperview()
        }

        foregroundMask.frame = .zero
        highlightedCategoryIndex = nil
    }

    func highlightCategory(atIndex i: Int, animated: Bool) {
        if highlightedCategoryIndex != nil, animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState, .curveEaseOut]) {
                self.highlightCategory(atIndex: i, animateScrollView: false)
            }
        } else {
            highlightCategory(atIndex: i)
        }
    }

    func highlightCategory(atIndex i: Int, animateScrollView: Bool = false) {
        highlightedCategoryIndex = i
        foregroundMask.frame = categoriesForeground.arrangedSubviews[i].frame

        scrollView.scrollRectToVisible(foregroundMask.frame, animated: animateScrollView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let i = highlightedCategoryIndex {
            highlightCategory(atIndex: i)
        }
    }

}
