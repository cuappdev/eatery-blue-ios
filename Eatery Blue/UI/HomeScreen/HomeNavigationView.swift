//
//  HomeNavigationView.swift
//  Eatery Blue
//
//  Created by William Ma on 1/8/22.
//

import UIKit

class HomeNavigationView: NavigationView {

    let logoRefreshControl = LogoRefreshControl()
    let searchButton = NavigationImageButton()

    private(set) var fadeInProgress: Double = 0

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        backgroundColor = UIColor(named: "EateryBlue")
        layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 8, right: 16)

        titleLabel.text = "Eatery"
        titleLabel.textColor = .white

        largeTitleLabel.text = "Eatery"
        largeTitleLabel.textColor = .white

        searchButton.image = UIImage(named: "Search")?.withRenderingMode(.alwaysTemplate)
        searchButton.tintColor = .white
        setRightButtons([searchButton])

        addSubview(logoRefreshControl)
    }

    private func setUpConstraints() {
        logoRefreshControl.width(36)
        logoRefreshControl.height(36)
        logoRefreshControl.bottomToTop(of: largeTitleLabel, offset: -4)
        logoRefreshControl.leading(to: layoutMarginsGuide)
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
