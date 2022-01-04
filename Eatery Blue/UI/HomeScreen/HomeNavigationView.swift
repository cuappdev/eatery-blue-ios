//
//  HomeNavigationView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/28/21.
//

import UIKit

class HomeNavigationView: UIView {

    let normalNavigationBar = UIView()
    let logoRefreshControl = LogoRefreshControl()
    let titleLabel = UILabel()
    let searchButton = ContainerView(content: UIImageView())

    let largeTitleLabel = UILabel()

    private(set) var fadeInProgress: Double = 0

    private var cachedNormalHeight: CGFloat? = nil
    private var cachedExpandedHeight: CGFloat? = nil

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
        backgroundColor = UIColor(named: "EateryBlue")

        addSubview(normalNavigationBar)
        setUpNormalNavigationBar()

        addSubview(largeTitleLabel)
        setUpLargeTitleLabel()

        addSubview(logoRefreshControl)
        setUpLogoRefreshControl()
    }

    private func setUpNormalNavigationBar() {
        normalNavigationBar.addSubview(titleLabel)
        setUpTitleLabel()

        normalNavigationBar.addSubview(searchButton)
        setUpSearchButton()
    }

    private func setUpTitleLabel() {
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.text = "Eatery"
    }

    private func setUpSearchButton() {
        searchButton.content.image = UIImage(named: "Search")?.withRenderingMode(.alwaysTemplate)
        searchButton.content.tintColor = .white
        searchButton.content.contentMode = .scaleAspectFit
    }

    private func setUpLargeTitleLabel() {
        largeTitleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        largeTitleLabel.textColor = .white
        largeTitleLabel.text = "Eatery"
    }

    private func setUpLogoRefreshControl() {
    }

    private func setUpConstraints() {
        normalNavigationBar.height(44)
        normalNavigationBar.edges(to: layoutMarginsGuide, excluding: .bottom)
        normalNavigationBar.bottomToSuperview(relation: .equalOrLess)

        titleLabel.leadingToTrailing(of: logoRefreshControl, offset: 8, relation: .equalOrGreater)
        titleLabel.topToSuperview()
        titleLabel.bottomToSuperview()
        titleLabel.centerXToSuperview()
        titleLabel.trailingToLeading(of: searchButton, offset: 8, relation: .equalOrLess)

        searchButton.centerYToSuperview()
        searchButton.width(24)
        searchButton.height(44)
        searchButton.trailingToSuperview()

        largeTitleLabel.setCompressionResistance(.required, for: .vertical)
        largeTitleLabel.edges(to: layoutMarginsGuide, excluding: .top)

        logoRefreshControl.width(36)
        logoRefreshControl.height(36)
        logoRefreshControl.bottomToTop(of: largeTitleLabel, offset: -4)
        logoRefreshControl.leading(to: layoutMarginsGuide)
    }

    func computeFullyExpandedHeight() -> CGFloat {
        let temporaryConstraint = largeTitleLabel.topToBottom(
            of: normalNavigationBar,
            offset: 0
        )

        defer {
            temporaryConstraint.isActive = false
        }

        return systemLayoutSizeFitting(
            CGSize(width: bounds.width, height: 0),
            withHorizontalFittingPriority: .defaultLow,
            verticalFittingPriority: .defaultHigh
        ).height
    }

    func computeNormalHeight() -> CGFloat {
        return systemLayoutSizeFitting(
            CGSize(width: bounds.width, height: 0),
            withHorizontalFittingPriority: .defaultLow,
            verticalFittingPriority: .defaultHigh
        ).height
    }

    func setFadeInProgress(_ progress: Double) {
        titleLabel.alpha = progress
        searchButton.alpha = progress
    }

    func setFadeInProgress(_ progress: Double, animated: Bool) {
        if progress == fadeInProgress {
            return
        }

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

}
