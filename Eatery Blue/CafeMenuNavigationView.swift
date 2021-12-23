//
//  CafeMenuNavigationView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/23/21.
//

import UIKit

class CafeMenuNavigationView: UIView {

    let backgroundView = UIView()

    let backButton = ContainerView(content: UIImageView())
    let titleLabel = UILabel()
    let favoriteButton = ContainerView(content: UIImageView())

    let scrollView = UIScrollView()
    let categoriesBackground = UIStackView()
    let categoriesForeground = UIStackView()
    let foregroundMask = PillView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()

        setFadeInProgress(1)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        addSubview(backgroundView)
        setUpBackgroundView()

        addSubview(backButton)
        setUpBackButton()

        addSubview(titleLabel)
        setUpTitleLabel()

        addSubview(favoriteButton)
        setUpFavoriteButton()

        addSubview(scrollView)
        setUpScrollView()
    }

    private func setUpBackgroundView() {
        backgroundView.backgroundColor = .white
    }

    private func setUpBackButton() {
        backButton.content.image = UIImage(named: "ArrowLeft")
        backButton.cornerRadius = 20
        backButton.shadowColor = UIColor(named: "Black")
        backButton.shadowOffset = CGSize(width: 0, height: 4)
        backButton.clippingView.backgroundColor = .white
        backButton.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }

    private func setUpTitleLabel() {
        titleLabel.font = .preferredFont(for: .title3, weight: .semibold)
        titleLabel.textColor = UIColor(named: "Black")
        titleLabel.textAlignment = .center
    }

    private func setUpFavoriteButton() {
        favoriteButton.content.image = UIImage(named: "FavoriteSelected")
        favoriteButton.cornerRadius = 20
        favoriteButton.shadowColor = UIColor(named: "Black")
        favoriteButton.shadowOffset = CGSize(width: 0, height: 4)
        favoriteButton.clippingView.backgroundColor = .white
        favoriteButton.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }

    private func setUpScrollView() {
        scrollView.bounces = false

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

        backButton.top(to: layoutMarginsGuide)
        backButton.leading(to: layoutMarginsGuide)
        backButton.width(40)
        backButton.height(40)

        titleLabel.leadingToTrailing(of: backButton)
        titleLabel.top(to: layoutMarginsGuide)
        titleLabel.height(40)
        titleLabel.trailingToLeading(of: favoriteButton)

        favoriteButton.top(to: layoutMarginsGuide)
        favoriteButton.trailing(to: layoutMarginsGuide)
        favoriteButton.width(40)
        favoriteButton.height(40)

        scrollView.topToBottom(of: titleLabel, offset: 12)
        scrollView.leadingToSuperview()
        scrollView.trailingToSuperview()
        scrollView.bottom(to: layoutMarginsGuide)

        setUpCategoriesStackViewConstraints(categoriesBackground)
        setUpCategoriesStackViewConstraints(categoriesForeground)
    }

    private func setUpCategoriesStackViewConstraints(_ stackView: UIStackView) {
        stackView.edgesToSuperview()
        stackView.height(to: scrollView)
    }

    func setFadeInProgress(_ progress: Double) {
        backgroundView.alpha = progress
        backButton.shadowOpacity = 0.25 * Float(1 - progress)
        favoriteButton.shadowOpacity = 0.25 * Float(1 - progress)
        titleLabel.alpha = progress
        scrollView.alpha = progress
    }

    func addCategory(_ title: String, onTap: (() -> Void)? = nil) {
        let backgroundContainer = ContainerView(content: UILabel())
        let foregroundContainer = ContainerView(content: UILabel())

        backgroundContainer.content.text = title
        foregroundContainer.content.text = backgroundContainer.content.text

        backgroundContainer.layoutMargins = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        foregroundContainer.layoutMargins = backgroundContainer.layoutMargins

        backgroundContainer.content.textColor = UIColor(named: "Gray05")
        foregroundContainer.content.textColor = .white

        categoriesBackground.addArrangedSubview(backgroundContainer)
        categoriesForeground.addArrangedSubview(foregroundContainer)

        backgroundContainer.on(UITapGestureRecognizer()) { _ in
            onTap?()
        }
        foregroundContainer.isUserInteractionEnabled = false
    }

    func selectCategory(atIndex i: Int, animated: Bool) {
        let action: () -> Void = {
            self.foregroundMask.frame = self.categoriesForeground.arrangedSubviews[i].frame
        }
        if animated {
            UIView.animate(withDuration: 0.25, animations: action)
        } else {
            action()
        }
    }

}
